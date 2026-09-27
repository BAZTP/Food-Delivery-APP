import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/food_category_model.dart';
import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';

class RestaurantProvider extends ChangeNotifier {
  final List<RestaurantModel> _restaurants = List.from(MockData.restaurants);
  final List<FoodCategoryModel> _categories = List.from(MockData.categories);
  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';
  final Set<String> _favoriteRestaurantIds = {};

  List<RestaurantModel> get restaurants => _restaurants;
  List<FoodCategoryModel> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteRestaurantIds => _favoriteRestaurantIds;

  bool isFavorite(String restaurantId) => _favoriteRestaurantIds.contains(restaurantId);

  void toggleFavorite(String restaurantId) {
    if (_favoriteRestaurantIds.contains(restaurantId)) {
      _favoriteRestaurantIds.remove(restaurantId);
    } else {
      _favoriteRestaurantIds.add(restaurantId);
    }
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filtered restaurants based on category and search query
  List<RestaurantModel> get filteredRestaurants {
    return _restaurants.where((restaurant) {
      final matchesCategory = _selectedCategoryId == 'cat_all' ||
          restaurant.categoryId == _selectedCategoryId ||
          restaurant.category.toLowerCase().contains(_selectedCategoryName.toLowerCase());

      final matchesSearch = _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.menu.any((item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.description.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get _selectedCategoryName {
    final cat = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _categories.first,
    );
    return cat.name;
  }

  // Filtered dishes for global search
  List<FoodItemModel> get searchDishes {
    if (_searchQuery.trim().isEmpty) return [];
    final all = MockData.allDishes;
    return all.where((dish) {
      return dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Popular dishes
  List<FoodItemModel> get popularDishes {
    return MockData.allDishes.where((d) => d.isPopular).toList();
  }

  // Featured restaurants
  List<RestaurantModel> get featuredRestaurants {
    return _restaurants.where((r) => r.isFeatured).toList();
  }

  // Favorite restaurants
  List<RestaurantModel> get favoriteRestaurants {
    return _restaurants.where((r) => _favoriteRestaurantIds.contains(r.id)).toList();
  }

  // Get by ID
  RestaurantModel? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
