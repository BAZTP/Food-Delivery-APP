import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_item_model.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_selector_modal.dart';
import '../../widgets/category_item.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/food_item_detail_sheet.dart';
import '../../widgets/section_header.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;

  const HomeScreen({
    super.key,
    required this.onNavigateToSearch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddressBottomSheet(BuildContext context) {
    AddressSelectorModal.show(context);
  }

  void _showNotificationsSheet(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final activeOrders = orderProvider.activeOrders;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Notificaciones 🔔',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),

            // Active orders notification
            if (activeOrders.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delivery_dining_rounded, color: Colors.blue),
                ),
                title: Text(
                  '${activeOrders.length} pedido${activeOrders.length > 1 ? 's' : ''} en curso',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Pedido ${activeOrders.first.id}: ${activeOrders.first.status.displayName}',
                ),
              ),

            // Cart notification
            if (cartProvider.itemCount > 0) ...[
              if (activeOrders.isNotEmpty) const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
                ),
                title: Text(
                  'Tienes ${cartProvider.itemCount} producto${cartProvider.itemCount > 1 ? 's' : ''} en tu carrito',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Total: \$${cartProvider.total.toStringAsFixed(2)} — ¡No olvides hacer tu pedido!'),
              ),
            ],

            const Divider(),

            // Promos
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer_rounded, color: AppColors.primary),
              ),
              title: const Text('¡20% OFF con código PIZZA20!', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Aplica en todas las pizzas gourmet y tradicionales en tu checkout.'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delivery_dining_rounded, color: AppColors.success),
              ),
              title: const Text('¡Envío GRATIS hoy!', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Disfruta de delivery sin costo en cualquier pedido a tu ubicación.'),
            ),

            if (activeOrders.isEmpty && cartProvider.itemCount == 0) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '✨ No tienes pedidos activos. ¡Explora nuestro menú y pide tu pizza favorita!',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addItemToCart(BuildContext context, FoodItemModel dish) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final pizzeria = restaurantProvider.pizzeria;

    // Open detail sheet so user can select size for pizzas
    FoodItemDetailSheet.show(
      context,
      foodItem: dish,
      restaurant: pizzeria,
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final user = authProvider.currentUser;
    final selectedAddress = authProvider.selectedAddress;
    final pizzeria = restaurantProvider.pizzeria;
    final categories = restaurantProvider.categories;
    final menuDishes = restaurantProvider.filteredMenuDishes;
    final popularDishes = restaurantProvider.popularDishes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER (GREETING + LOCATION PICKER + NOTIFICATIONS)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location & Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user != null ? '¡Hola, ${user.name.split(' ').first}! 👋' : '¡Bienvenido! 👋',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '🍕 PIZZERÍA ARTESANAL',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Clickable Address Pill
                          InkWell(
                            onTap: () => _showAddressBottomSheet(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.primary,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      selectedAddress.fullAddress,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notification Icon
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Badge(
                          smallSize: 8,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onPressed: () => _showNotificationsSheet(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. PIZZERIA HERO BRAND CARD
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Background Image
                      CustomNetworkImage(
                        imageUrl: pizzeria.bannerUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.85),
                            ],
                          ),
                        ),
                      ),
                      // Pizzeria Info content
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, color: Colors.white, size: 8),
                                      SizedBox(width: 4),
                                      Text(
                                        'ABIERTO AHORA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '🇮🇹 Forno a Legna',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              pizzeria.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Quick stats
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 3),
                                Text(
                                  '${pizzeria.rating} (${pizzeria.reviewCount})',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time_filled_rounded, color: Colors.white70, size: 15),
                                const SizedBox(width: 3),
                                Text(
                                  pizzeria.deliveryTime,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.electric_moped_rounded, color: Colors.white70, size: 16),
                                const SizedBox(width: 3),
                                const Text(
                                  'Envío GRATIS',
                                  style: TextStyle(color: Color(0xFF66FFA6), fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. SEARCH BAR
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Buscar pizza, calzone, entradas...',
                  onChanged: (val) {
                    restaurantProvider.setSearchQuery(val);
                  },
                  onClear: () {
                    restaurantProvider.setSearchQuery('');
                  },
                ),

                const SizedBox(height: 18),

                // 4. PROMO BANNER CAROUSEL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFFF7043),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PROMO ESPECIAL NAPOLI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '2x1 en Pizzas Grandes\nMartes y Jueves',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Cupón: PIZZA20 al pagar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🍕🔥', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. PIZZA CATEGORIES
                const Text(
                  'Nuestra Carta Artesanal 🍕',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = restaurantProvider.selectedCategoryId == category.id;
                      return CategoryItem(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => restaurantProvider.selectCategory(category.id),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 6. POPULAR SPECIALTIES (IF "TODAS" IS SELECTED)
                if (popularDishes.isNotEmpty &&
                    restaurantProvider.selectedCategoryId == 'cat_all' &&
                    restaurantProvider.searchQuery.isEmpty) ...[
                  SectionHeader(
                    title: 'Las Favoritas de Napoli 🔥',
                    subtitle: 'Las más pedidas por nuestros clientes',
                    actionText: null,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularDishes.length,
                      itemBuilder: (context, index) {
                        final dish = popularDishes[index];

                        return Container(
                          width: 170,
                          margin: const EdgeInsets.only(right: 14, bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => FoodItemDetailSheet.show(
                                context,
                                foodItem: dish,
                                restaurant: pizzeria,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomNetworkImage(
                                    imageUrl: dish.imageUrl,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dish.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${dish.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _addItemToCart(context, dish),
                                              child: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primarySoft,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 15,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 7. MENU LIST (ACCORDING TO CATEGORY AND SEARCH)
                SectionHeader(
                  title: restaurantProvider.selectedCategoryId == 'cat_all'
                      ? 'Menú Completo (${menuDishes.length})'
                      : '${categories.firstWhere((c) => c.id == restaurantProvider.selectedCategoryId, orElse: () => categories.first).name} (${menuDishes.length})',
                  subtitle: 'Horneadas al momento con masa madre fresca',
                  actionText: null,
                ),

                if (menuDishes.isEmpty)
                  EmptyStateView(
                    icon: Icons.local_pizza_outlined,
                    title: 'No encontramos pizzas',
                    message: 'Intenta con otro término de búsqueda o selecciona otra categoría.',
                    buttonText: 'Ver todo el menú',
                    onButtonPressed: () {
                      _searchController.clear();
                      restaurantProvider.setSearchQuery('');
                      restaurantProvider.selectCategory('cat_all');
                    },
                  )
                else
                  ...menuDishes.map((dish) {
                    return FoodItemCard(
                      foodItem: dish,
                      onTap: () => FoodItemDetailSheet.show(
                        context,
                        foodItem: dish,
                        restaurant: pizzeria,
                      ),
                      onAdd: () => _addItemToCart(context, dish),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
