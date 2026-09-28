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
  final Set<String> _favoriteDishIds = {};

  List<RestaurantModel> get restaurants => _restaurants;
  List<FoodCategoryModel> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteDishIds => _favoriteDishIds;

  // Dedicated single restaurant
  RestaurantModel get pizzeria => _restaurants.first;

  bool isFavorite(String id) => _favoriteDishIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteDishIds.contains(id)) {
      _favoriteDishIds.remove(id);
    } else {
      _favoriteDishIds.add(id);
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

  // Filtered dishes for current pizzeria category & search
  List<FoodItemModel> get filteredMenuDishes {
    return pizzeria.menu.where((item) {
      final matchesCategory = _selectedCategoryId == 'cat_all' || item.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Filtered restaurants (keeps backward compatibility for widgets using it)
  List<RestaurantModel> get filteredRestaurants {
    return _restaurants;
  }

  // Dishes for global search
  List<FoodItemModel> get searchDishes {
    if (_searchQuery.trim().isEmpty) return pizzeria.menu;
    return pizzeria.menu.where((dish) {
      return dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Popular dishes
  List<FoodItemModel> get popularDishes {
    return pizzeria.menu.where((d) => d.isPopular).toList();
  }

  // Featured restaurants
  List<RestaurantModel> get featuredRestaurants => _restaurants;

  // Get restaurant by ID
  RestaurantModel? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return _restaurants.isNotEmpty ? _restaurants.first : null;
    }
  }
}
