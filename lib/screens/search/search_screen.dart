import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_item.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/food_item_card.dart';
import '../../widgets/food_item_detail_sheet.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/section_header.dart';
import '../restaurant/restaurant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    _controller.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final filteredRestaurants = restaurantProvider.filteredRestaurants;
    final searchDishes = restaurantProvider.searchDishes;
    final categories = restaurantProvider.categories;
    final hasSearch = restaurantProvider.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explorar & Buscar'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            CustomSearchBar(
              controller: _controller,
              hintText: 'Buscar hamburguesa, sushi, pizza...',
              onChanged: (val) {
                restaurantProvider.setSearchQuery(val);
              },
              onClear: () {
                restaurantProvider.setSearchQuery('');
              },
            ),

            const SizedBox(height: 16),

            // Horizontal Categories Filter
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = restaurantProvider.selectedCategoryId == cat.id;
                  return CategoryItem(
                    category: cat,
                    isSelected: isSelected,
                    onTap: () => restaurantProvider.selectCategory(cat.id),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Quick suggestion tags if no search entered
            if (!hasSearch) ...[
              const Text(
                'Búsquedas populares',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Smash Bacon',
                  'Pizza Pepperoni',
                  'Poke Bowl',
                  'Alitas Buffalo',
                  'Cheesecake',
                  'Envío Gratis',
                ].map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () {
                      _controller.text = tag;
                      restaurantProvider.setSearchQuery(tag);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Search Dishes Results (if any)
            if (hasSearch && searchDishes.isNotEmpty) ...[
              SectionHeader(
                title: 'Platillos coincidentes',
                subtitle: '${searchDishes.length} resultados encontrados',
              ),
              ...searchDishes.map((dish) {
                final restaurant = restaurantProvider.getRestaurantById(dish.restaurantId);
                if (restaurant == null) return const SizedBox.shrink();
                return FoodItemCard(
                  foodItem: dish,
                  onTap: () => FoodItemDetailSheet.show(
                    context,
                    foodItem: dish,
                    restaurant: restaurant,
                  ),
                  onAdd: () => FoodItemDetailSheet.show(
                    context,
                    foodItem: dish,
                    restaurant: restaurant,
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Restaurants Results
            SectionHeader(
              title: hasSearch ? 'Restaurantes' : 'Todos los restaurantes',
              subtitle: '${filteredRestaurants.length} lugares disponibles',
            ),

            if (filteredRestaurants.isEmpty && (!hasSearch || searchDishes.isEmpty))
              EmptyStateView(
                icon: Icons.search_off_rounded,
                title: 'Sin resultados',
                message: 'No encontramos ningún resultado para "${_controller.text}". Intenta con otra palabra o categoría.',
                buttonText: 'Limpiar búsqueda',
                onButtonPressed: () {
                  _controller.clear();
                  restaurantProvider.setSearchQuery('');
                  restaurantProvider.selectCategory('cat_all');
                },
              )
            else
              ...filteredRestaurants.map((restaurant) {
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
    );
  }
}
