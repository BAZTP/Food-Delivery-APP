import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_selector_modal.dart';
import '../../widgets/category_item.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/food_item_detail_sheet.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/section_header.dart';
import '../restaurant/restaurant_detail_screen.dart';

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
              'Notificaciones y Promos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
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
              title: const Text('¡Cupón del 20% disponible!', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Usa el código FOOD20 en tu próximo checkout para un descuento especial.'),
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
                child: const Icon(Icons.electric_moped_rounded, color: AppColors.success),
              ),
              title: const Text('Envío gratis en Pizza Express', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Disfruta de delivery sin costo durante todo el fin de semana.'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final user = authProvider.currentUser;
    final selectedAddress = authProvider.selectedAddress;
    final restaurants = restaurantProvider.filteredRestaurants;
    final categories = restaurantProvider.categories;
    final popularDishes = restaurantProvider.popularDishes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting and Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? '¡Hola, ${user.name.split(' ').first}! 👋' : '¡Bienvenido! 👋',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () => _showAddressBottomSheet(context),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    selectedAddress.fullAddress,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

                const SizedBox(height: 18),

                // 2. SEARCH BAR (LARGE)
                CustomSearchBar(
                  controller: _searchController,
                  readOnly: true,
                  onTap: widget.onNavigateToSearch,
                  hintText: '¿Qué se te antoja comer hoy?',
                ),

                const SizedBox(height: 20),

                // 3. PROMO BANNER CAROUSEL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF5A36),
                        Color(0xFFFF8A5C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PROMO DE BIENVENIDA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hasta 30% OFF\nen tu primer pedido',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Usa el cupón: QUICK10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Food emoji/visual sticker
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '🍔🍕',
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // 4. CATEGORIES
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
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

                const SizedBox(height: 22),

                // 5. POPULAR DISHES (QUICK PREVIEW)
                if (popularDishes.isNotEmpty && restaurantProvider.selectedCategoryId == 'cat_all') ...[
                  SectionHeader(
                    title: 'Platillos Populares 🔥',
                    subtitle: 'Los favoritos de la comunidad hoy',
                    actionText: 'Explorar',
                    onActionTap: widget.onNavigateToSearch,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularDishes.length,
                      itemBuilder: (context, index) {
                        final dish = popularDishes[index];
                        final restaurant = restaurantProvider.getRestaurantById(dish.restaurantId);
                        if (restaurant == null) return const SizedBox.shrink();

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
                                restaurant: restaurant,
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
                                            fontSize: 13.5,
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
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primarySoft,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 14,
                                                color: AppColors.primary,
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

                // 6. RESTAURANTS LIST
                SectionHeader(
                  title: 'Restaurantes Disponibles',
                  subtitle: '${restaurants.length} lugares cerca de ti',
                  actionText: null,
                ),

                if (restaurants.isEmpty)
                  EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No encontramos restaurantes',
                    message: 'Intenta seleccionando otra categoría o cambiando tus filtros.',
                    buttonText: 'Ver todas las categorías',
                    onButtonPressed: () => restaurantProvider.selectCategory('cat_all'),
                  )
                else
                  ...restaurants.map((restaurant) {
                    return RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
