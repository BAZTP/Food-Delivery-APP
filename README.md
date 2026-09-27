# 🍔 QuickFood - Food Delivery App

Aplicación móvil moderna de delivery de comida desarrollada en **Flutter** y **Dart** con diseño **Material 3**, arquitectura limpia y modular, inspirada en las mejores experiencias de usuario de Uber Eats y Rappi pero con branding y diseño originales.

---

## 🚀 Características Principales

1. **🔐 Autenticación & Usuarios:**
   - Inicio de sesión y registro interactivo.
   - Botón de **"Acceso Rápido Demo"** para ingresar con un solo toque como cliente de prueba (*Carlos Mendoza*).
2. **🏠 Home & Exploración:**
   - Selector dinámico de dirección de entrega con modal de direcciones guardadas.
   - Carrusel de promociones y descuentos exclusivos (`QUICK10`, `FOOD20`).
   - Barra de búsqueda con filtros por chips de categorías (Hamburguesas, Pizza, Sushi, Pollo, Ensaladas, Postres, Bebidas).
   - Tarjetas de restaurantes con calificaciones, tiempo estimado y costos de envío.
3. **🔍 Búsqueda en Tiempo Real:**
   - Filtrado instantáneo por nombre de restaurante y platos específicos.
4. **🍽️ Menú & Detalle del Restaurante:**
   - Banner hero colapsable con información del local.
   - Pestañas organizadas por categorías de menú.
   - Hoja modal interactiva para seleccionar cantidades, añadir notas especiales a cocina y agregar al carrito.
5. **🛒 Carrito Inteligente:**
   - Modificación dinámica de cantidades (+ / -) y eliminación de ítems.
   - Motor de validación de cupones de descuento.
   - Desglose transparente de costos: Subtotal, Tarifa de Servicio, Costo de Envío y Total.
6. **💳 Checkout & Pagos:**
   - Selección de dirección de entrega.
   - Métodos de pago simulados (Tarjeta de Crédito/Débito, Efectivo, Billetera Digital).
   - Creación y confirmación inmediata de la orden.
7. **📍 Rastreo de Pedido en Tiempo Real:**
   - Mapa interactivo con ruta y pin del repartidor.
   - Tarjeta con información y teléfono del repartidor asignado.
   - Línea de tiempo de 5 etapas (*Recibido ➔ Preparando ➔ Listo para recoger ➔ En camino ➔ Entregado*) con progresión automática o simulación manual por botón.
8. **📦 Historial & Perfil:**
   - Historial de pedidos divididos en "En Curso" y "Pasados" con función de **Repetir Pedido**.
   - Gestión de libreta de direcciones y perfil del usuario.

---

## 🎨 Identidad Visual & Paleta de Colores

- **Color Primario:** `#FF5A36` (Naranja apetitoso y vibrante)
- **Fondo:** `#F8F8F8` (Limpio y minimalista)
- **Superficies:** `#FFFFFF` (Tarjetas limpias con bordes redondeados y sombras sutiles)
- **Texto Principal:** `#222222`
- **Texto Secundario:** `#777777`

---

## 📂 Estructura del Proyecto

```text
lib/
├── data/              # Datos simulados y catálogo gastronómico (MockData)
├── models/            # Modelos de dominio (User, Restaurant, FoodItem, CartItem, Order, Address)
├── providers/         # Gestión de estado reactiva con ChangeNotifier (Auth, Cart, Order, Restaurant)
├── screens/           # Pantallas de la aplicación
│   ├── auth/          # Login y Registro
│   ├── home/          # Pantalla principal y catálogo
│   ├── search/        # Búsqueda y filtros
│   ├── restaurant/    # Menú y detalles de restaurantes
│   ├── cart/          # Carrito de compras y cupones
│   ├── checkout/      # Pasarela y confirmación
│   ├── orders/        # Lista de pedidos y seguimiento en vivo
│   └── profile/       # Perfil y gestión de direcciones
├── theme/             # Tema Material 3, colores y estilos globales
└── widgets/           # Componentes reutilizables (Cards, SearchBar, Headers, Modals)
```

---

## 🛠️ Tecnologías Utilizadas

- **Framework:** [Flutter 3.x](https://flutter.dev/)
- **Lenguaje:** [Dart 3.x](https://dart.dev/)
- **Diseño:** Material Design 3
- **State Management:** `provider`
- **Plataformas Soportadas:** Android (Principal), Web, Windows Desktop

---

## ⚙️ Cómo Ejecutar el Proyecto

### Requisitos Previos
- Flutter SDK instalado y configurado en el `PATH`.
- Android Studio / VS Code con extensiones de Flutter y Dart.

### Instalación de Dependencias
```bash
flutter pub get
```

### Ejecutar en Modo Web
```bash
flutter run -d chrome
```

### Ejecutar en Android (Emulador o Dispositivo Físico)
```bash
flutter run
```

### Compilar APK para Móvil (Release)
```bash
flutter build apk --release
```
El archivo generado se ubicará en:
`build/app/outputs/flutter-apk/app-release.apk`
