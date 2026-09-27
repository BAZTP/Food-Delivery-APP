-- ==============================================================================
-- 🍔 QUICKFOOD - ESQUEMA COMPLETO PARA SUPABASE (POSTGRESQL)
-- ==============================================================================
-- Instrucciones:
-- 1. Ve a tu panel de Supabase: https://supabase.com
-- 2. Entra en tu proyecto 'FoodDelivery'
-- 3. En el menú izquierdo ve a 'SQL Editor' (ícono >_)
-- 4. Haz clic en 'New query', pega todo este contenido y presiona 'RUN' (verde).
-- ==============================================================================

-- 1. EXTENSIONES NECESARIAS
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- 2. TABLA DE PERFILES DE USUARIO (Vinculada a auth.users de Supabase)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  email text,
  phone text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Políticas de Seguridad (RLS) para Perfiles
alter table public.profiles enable row level security;

drop policy if exists "Perfiles lectura pública" on public.profiles;
create policy "Perfiles lectura pública" 
  on public.profiles for select using (true);

drop policy if exists "Usuarios insertan su propio perfil" on public.profiles;
create policy "Usuarios insertan su propio perfil" 
  on public.profiles for insert with check (auth.uid() = id);

drop policy if exists "Usuarios editan su propio perfil" on public.profiles;
create policy "Usuarios editan su propio perfil" 
  on public.profiles for update using (auth.uid() = id);

-- 3. TRIGGER AUTOMÁTICO PARA CREAR PERFIL AL REGISTRARSE EN SUPABASE AUTH
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Usuario QuickFood'),
    new.email,
    coalesce(new.raw_user_meta_data->>'phone', '')
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    phone = excluded.phone;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 4. TABLA DE RESTAURANTES
create table if not exists public.restaurants (
  id text primary key,
  name text not null,
  category text not null,
  image_url text not null,
  rating numeric(2,1) default 4.5,
  rating_count integer default 100,
  delivery_time text default '25-35 min',
  delivery_fee numeric(10,2) default 1.50,
  address text,
  phone text,
  is_promoted boolean default false,
  is_open boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.restaurants enable row level security;
drop policy if exists "Restaurantes públicos" on public.restaurants;
create policy "Restaurantes públicos" 
  on public.restaurants for select using (true);

-- 5. TABLA DE PRODUCTOS / MENÚ DE COMIDA
create table if not exists public.food_items (
  id text primary key,
  restaurant_id text references public.restaurants(id) on delete cascade,
  name text not null,
  description text,
  price numeric(10,2) not null,
  image_url text not null,
  category text not null,
  is_popular boolean default false,
  is_available boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.food_items enable row level security;
drop policy if exists "Comidas públicas" on public.food_items;
create policy "Comidas públicas" 
  on public.food_items for select using (true);

-- 6. TABLA DE DIRECCIONES DE USUARIO
create table if not exists public.addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade,
  label text not null,
  street text not null,
  number text not null,
  reference text,
  city text default 'Ciudad',
  is_default boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.addresses enable row level security;
drop policy if exists "Usuarios gestionan sus propias direcciones" on public.addresses;
create policy "Usuarios gestionan sus propias direcciones" 
  on public.addresses for all using (auth.uid() = user_id);

-- 7. TABLA DE PEDIDOS (ORDERS)
create table if not exists public.orders (
  id text primary key,
  user_id uuid references auth.users on delete set null,
  restaurant_id text references public.restaurants(id) on delete set null,
  restaurant_name text,
  status text default 'received',
  subtotal numeric(10,2) not null,
  delivery_fee numeric(10,2) not null,
  service_fee numeric(10,2) not null default 1.00,
  discount numeric(10,2) default 0.0,
  total numeric(10,2) not null,
  delivery_address text not null,
  payment_method text not null,
  driver_name text default 'Carlos Mendoza',
  driver_phone text default '+57 300 123 4567',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.orders enable row level security;
drop policy if exists "Permitir crear pedidos" on public.orders;
create policy "Permitir crear pedidos" 
  on public.orders for insert with check (true);

drop policy if exists "Usuarios ven sus propios pedidos" on public.orders;
create policy "Usuarios ven sus propios pedidos" 
  on public.orders for select using (true);

-- 8. TABLA DE ITEMS DE PEDIDO (ORDER_ITEMS)
create table if not exists public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id text references public.orders(id) on delete cascade,
  food_item_id text,
  food_item_name text not null,
  food_item_price numeric(10,2) not null,
  food_item_image text,
  quantity integer not null default 1,
  special_instructions text
);

alter table public.order_items enable row level security;
drop policy if exists "Permitir insertar items de orden" on public.order_items;
create policy "Permitir insertar items de orden" 
  on public.order_items for insert with check (true);

drop policy if exists "Permitir leer items de orden" on public.order_items;
create policy "Permitir leer items de orden" 
  on public.order_items for select using (true);

-- ==============================================================================
-- 9. POBLADO DE DATOS INICIALES (RESTAURANTES Y MENÚ)
-- ==============================================================================

-- A. RESTAURANTES
insert into public.restaurants (id, name, category, image_url, rating, rating_count, delivery_time, delivery_fee, address, phone, is_promoted, is_open)
values
  ('rest_001', 'Burger House Gourmet', 'Hamburguesas', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800', 4.8, 340, '20-30 min', 1.50, 'Av. Principal #45-12', '+57 301 234 5678', true, true),
  ('rest_002', 'Pizza Napoli Artesanal', 'Pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800', 4.7, 520, '25-40 min', 2.00, 'Calle 10 #23-45', '+57 302 345 6789', true, true),
  ('rest_003', 'Sushi Zen & Wok', 'Sushi', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800', 4.9, 195, '35-50 min', 2.50, 'Cra. 15 #85-30', '+57 303 456 7890', false, true),
  ('rest_004', 'Crispy Chicken Lab', 'Pollo', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=800', 4.6, 280, '15-25 min', 1.20, 'Av. 68 #11-20', '+57 304 567 8901', false, true),
  ('rest_005', 'Green Bowl & Fresh', 'Ensaladas', 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800', 4.8, 145, '20-35 min', 1.50, 'Calle 72 #9-50', '+57 305 678 9012', false, true),
  ('rest_006', 'Sweet Dreams Bakery', 'Postres', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800', 4.9, 410, '15-30 min', 1.80, 'Cra. 11 #93-10', '+57 306 789 0123', true, true)
on conflict (id) do update set
  name = excluded.name,
  category = excluded.category,
  image_url = excluded.image_url,
  rating = excluded.rating,
  rating_count = excluded.rating_count,
  delivery_time = excluded.delivery_time,
  delivery_fee = excluded.delivery_fee;

-- B. PLATOS Y PRODUCTOS DEL MENÚ
insert into public.food_items (id, restaurant_id, name, description, price, image_url, category, is_popular, is_available)
values
  -- Burger House
  ('bh_01', 'rest_001', 'Smash Bacon Supreme', 'Doble carne de res madurada smash, queso cheddar americano fundido, tocineta crujiente ahumada y salsa especial de la casa.', 9.50, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', 'Hamburguesas', true, true),
  ('bh_02', 'rest_001', 'Triple Cheeseburger Master', 'Tres discos de carne smash, triple queso gouda y monterey jack, cebolla caramelizada y pepinillos agridulces.', 11.00, 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=600', 'Hamburguesas', true, true),
  ('bh_03', 'rest_001', 'Papas Rústicas con Trufa & Parmesano', 'Papas cortadas a mano con piel, aromatizadas con aceite de trufa blanca y lluvia de queso parmesano.', 4.50, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', 'Acompañamientos', false, true),
  ('bh_04', 'rest_001', 'Aros de Cebolla Crujientes', 'Aros de cebolla rebozados con cerveza artesanal servidos con salsa barbacoa ahumada.', 3.80, 'https://images.unsplash.com/photo-1639024471287-032f66e5f80b?w=600', 'Acompañamientos', false, true),
  ('bh_05', 'rest_001', 'Milkshake de Oreo & Dulce de Leche', 'Batido espeso de helado de vainilla artesanal con trozos crocantes de galleta Oreo y salsa de arequipe.', 4.90, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600', 'Bebidas', true, true),

  -- Pizza Napoli
  ('pz_01', 'rest_002', 'Pizza Margherita D.O.P.', 'Salsa de tomate San Marzano, mozzarella di bufala fresca, albahaca fresca y toque de aceite de oliva extra virgen.', 12.50, 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600', 'Pizzas Tradicionales', true, true),
  ('pz_02', 'rest_002', 'Pizza Cuatro Quesos & Miel de Trufa', 'Mezcla gourmet de gorgonzola, parmesano reggiano, provolone ahumado, mozzarella y sutil hilo de miel de trufa.', 14.90, 'https://images.unsplash.com/photo-1573821663912-569905455b1c?w=600', 'Pizzas Especiales', true, true),
  ('pz_03', 'rest_002', 'Pizza Pepperoni Piccante', 'Mozzarella, pepperoni artesanal curado, orégano silvestre y hojuelas de chile seco.', 13.50, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600', 'Pizzas Tradicionales', true, true),
  ('pz_04', 'rest_002', 'Palitroques de Ajo & Finas Hierbas', 'Masa madre horneada con mantequilla de ajo confitado, romero fresco y dip de salsa marinara.', 5.20, 'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?w=600', 'Entradas', false, true),
  ('pz_05', 'rest_002', 'Tiramisú Clásico Italiano', 'Bizcochos soletilla empapados en café espresso fuerte, crema suave de mascarpone y cacao amargo.', 5.50, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600', 'Postres', true, true),

  -- Sushi Zen & Wok
  ('su_01', 'rest_003', 'Salmon Supreme Roll (10 bocados)', 'Relleno de salmón fresco y queso crema Philadelphia, envuelto en aguacate con topping de salsa tare y ajonjolí.', 12.90, 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600', 'Sushi Rolls', true, true),
  ('su_02', 'rest_003', 'Ebi Crunch Roll (10 bocados)', 'Langostinos crocantes apanados en panko, aguacate, cubierto con tártaro de salmón y salsa fuji.', 11.50, 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=600', 'Sushi Rolls', true, true),
  ('su_03', 'rest_003', 'Wok de Pollo Teriyaki & Vegetales', 'Fideos ramen salteados al fuego wok con vegetales de temporada, pechuga de pollo y salsa teriyaki casera.', 10.50, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600', 'Woks & Fideos', false, true),
  ('su_04', 'rest_003', 'Gyozas Japonesas al Vapor (5 uds)', 'Empanadillas rellenas de cerdo y cebollín con salsa ponzu cítrica de soya.', 6.00, 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600', 'Entradas', false, true),
  ('su_05', 'rest_003', 'Edamame con Sal Marina de Maldon', 'Vainas de soya tiernas al vapor servidas con escamas de sal marina.', 4.80, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600', 'Entradas', false, true),

  -- Crispy Chicken Lab
  ('ch_01', 'rest_004', 'Combo 8 Tenders Extracrujientes', 'Tiras de pechuga 100% natural marinadas 24h en suero de leche, papas fritas y dos salsas a elección.', 9.90, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600', 'Combos', true, true),
  ('ch_02', 'rest_004', 'Sándwich Hot Chicken Nashville', 'Pechuga frita crujiente bañada en aceite de especias picantes de Nashville, ensalada coleslaw fresca y pepinillos en pan brioche tostado.', 8.50, 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?w=600', 'Sándwiches', true, true),
  ('ch_03', 'rest_004', 'Alitas Glaseadas BBQ Honey (12 uds)', 'Alitas doradas bañadas en reducción de miel de abejas y barbacoa ahumada, con dip de blue cheese.', 11.20, 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600', 'Alitas', true, true),
  ('ch_04', 'rest_004', 'Papas Fritas Curly Seasoned', 'Papas rizadas sazonadas con páprika, ajo y cebolla tostada.', 3.50, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600', 'Acompañamientos', false, true),

  -- Green Bowl & Fresh
  ('gb_01', 'rest_005', 'Bowl Salmón & Aguacate Poke', 'Base de arroz de sushi o quinoa orgánica, salmón fresco en cubos, edamame, mango maduro, rábano y vinagreta sésamo.', 11.90, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600', 'Poke Bowls', true, true),
  ('gb_02', 'rest_005', 'Ensalada César con Pollo Grillé', 'Mix de lechugas romanas, pechuga de pollo a la plancha, crutones de masa madre, lascas de parmesano y aderezo césar tradicional.', 8.90, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600', 'Ensaladas', false, true),
  ('gb_03', 'rest_005', 'Wrap Mediterráneo de Falafel', 'Tortilla de trigo integral con croquetas de garbanzo falafel, hummus de tahini, tomate cherry y pepino fresco.', 7.50, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600', 'Wraps', false, true),
  ('gb_04', 'rest_005', 'Smoothie Verde Detox & Antiox', 'Manzana verde fresca, espinaca tierna, jengibre, piña colada y agua de coco.', 4.50, 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=600', 'Bebidas Saludables', true, true),

  -- Sweet Dreams Bakery
  ('sw_01', 'rest_006', 'Cheesecake New York de Frutos Rojos', 'Cremosa base de queso horneado al estilo neoyorquino sobre galleta de mantequilla, cubierto con coulis de fresa y moras.', 5.80, 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=600', 'Tortas & Pasteles', true, true),
  ('sw_02', 'rest_006', 'Volcán de Chocolate Belga Fundido', 'Bizcocho tibio de chocolate amargo al 70% con corazón de chocolate líquido fundido.', 6.20, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600', 'Postres Calientes', true, true),
  ('sw_03', 'rest_006', 'Box 4 Cupcakes Red Velvet & Zanahoria', 'Surtido de cupcakes esponjosos con frosting cremoso de queso crema y vainilla bourbon.', 8.50, 'https://images.unsplash.com/photo-1587668178277-295251f900ce?w=600', 'Cupcakes', false, true),
  ('sw_04', 'rest_006', 'Café Latte Vainilla Francesa', 'Doble shot de espresso de altura con leche texturizada y extracto natural de vainilla francesa.', 3.50, 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=600', 'Cafetería', false, true)
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  image_url = excluded.image_url,
  category = excluded.category,
  is_popular = excluded.is_popular,
  is_available = excluded.is_available;
