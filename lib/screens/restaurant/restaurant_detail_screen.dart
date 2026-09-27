import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/food_item_detail_sheet.dart';
import '../cart/cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String _selectedSubCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isFavorite = restaurantProvider.isFavorite(restaurant.id);

    // Filter menu by subcategory
    final menuItems = restaurant.menu;
    final availableCategories = ['Todos', ...{...menuItems.map((e) => e.categoryId)}.map((catId) {
      final found = restaurantProvider.categories.firstWhere(
        (c) => c.id == catId,
        orElse: () => restaurantProvider.categories.first,
      );
      return found.name;
    })];

    final filteredMenu = _selectedSubCategory == 'Todos'
        ? menuItems
        : menuItems.where((item) {
            final cat = restaurantProvider.categories.firstWhere(
              (c) => c.id == item.categoryId,
              orElse: () => restaurantProvider.categories.first,
            );
            return cat.name == _selectedSubCategory;
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. COLLAPSIBLE APP BAR WITH BANNER
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? AppColors.primary : AppColors.textPrimary,
                      ),
                      onPressed: () => restaurantProvider.toggleFavorite(restaurant.id),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        imageUrl: restaurant.bannerUrl,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Promotion badge if exists
                      if (restaurant.hasPromo)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.promo!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. RESTAURANT INFO HEADER
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        restaurant.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Badges Row
                      Row(
                        children: [
                          // Rating
                          _buildBadge(
                            icon: Icons.star_rounded,
                            iconColor: AppColors.star,
                            text: '${restaurant.rating} (${restaurant.reviewCount})',
                            bgColor: AppColors.star.withOpacity(0.12),
                          ),
                          const SizedBox(width: 8),
                          // Delivery Time
                          _buildBadge(
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.textSecondary,
                            text: restaurant.deliveryTime,
                            bgColor: AppColors.chipBackground,
                          ),
                          const SizedBox(width: 8),
                          // Delivery Fee
                          _buildBadge(
                            icon: Icons.delivery_dining_rounded,
                            iconColor: restaurant.hasFreeDelivery ? AppColors.success : AppColors.primary,
                            text: restaurant.hasFreeDelivery
                                ? 'Envío GRATIS'
                                : 'Envío \$${restaurant.deliveryFee.toStringAsFixed(2)}',
                            bgColor: restaurant.hasFreeDelivery
                                ? AppColors.successSoft
                                : AppColors.primarySoft,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // 3. MENU CATEGORY FILTER TABS
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: availableCategories.map((catName) {
                        final isSelected = _selectedSubCategory == catName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(catName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedSubCategory = catName);
                              }
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.chipBackground,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 4. MENU ITEMS LIST
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredMenu[index];
                      return FoodItemCard(
                        foodItem: item,
                        onTap: () => FoodItemDetailSheet.show(
                          context,
                          foodItem: item,
                          restaurant: restaurant,
                        ),
                        onAdd: () {
                          final added = cartProvider.addItem(item, restaurant);
                          if (!added) {
                            FoodItemDetailSheet.show(
                              context,
                              foodItem: item,
                              restaurant: restaurant,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡${item.name} agregado al carrito!'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.primaryDark,
                              ),
                            );
                          }
                        },
                      );
                    },
                    childCount: filteredMenu.length,
                  ),
                ),
              ),

              // Space for bottom floating bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),

          // 5. FLOATING BOTTOM CART BAR
          if (cartProvider.itemCount > 0)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ver Carrito',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${cartProvider.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
