import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  RestaurantModel? _currentRestaurant;
  String _appliedCoupon = '';
  double _discountPercent = 0.0;

  Map<String, CartItemModel> get items => _items;
  List<CartItemModel> get itemsList => _items.values.toList();
  RestaurantModel? get currentRestaurant => _currentRestaurant;
  String get appliedCoupon => _appliedCoupon;
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  // Add item with restaurant check
  // Returns true if added, false if requires user confirmation to replace restaurant
  bool addItem(FoodItemModel foodItem, RestaurantModel restaurant, {int quantity = 1, String specialInstructions = ''}) {
    if (_currentRestaurant != null && _currentRestaurant!.id != restaurant.id && _items.isNotEmpty) {
      // Trying to add from a different restaurant
      return false;
    }

    _currentRestaurant = restaurant;

    if (_items.containsKey(foodItem.id)) {
      _items[foodItem.id]!.quantity += quantity;
    } else {
      _items[foodItem.id] = CartItemModel(
        id: 'cart_${foodItem.id}',
        foodItem: foodItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );
    }

    notifyListeners();
    return true;
  }

  // Force add by clearing old restaurant items
  void forceAddItem(FoodItemModel foodItem, RestaurantModel restaurant, {int quantity = 1, String specialInstructions = ''}) {
    clearCart();
    addItem(foodItem, restaurant, quantity: quantity, specialInstructions: specialInstructions);
  }

  void incrementQuantity(String foodItemId) {
    if (_items.containsKey(foodItemId)) {
      _items[foodItemId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String foodItemId) {
    if (!_items.containsKey(foodItemId)) return;

    if (_items[foodItemId]!.quantity > 1) {
      _items[foodItemId]!.quantity--;
    } else {
      _items.remove(foodItemId);
      if (_items.isEmpty) {
        _currentRestaurant = null;
        _appliedCoupon = '';
        _discountPercent = 0.0;
      }
    }
    notifyListeners();
  }

  void removeItem(String foodItemId) {
    _items.remove(foodItemId);
    if (_items.isEmpty) {
      _currentRestaurant = null;
      _appliedCoupon = '';
      _discountPercent = 0.0;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentRestaurant = null;
    _appliedCoupon = '';
    _discountPercent = 0.0;
    notifyListeners();
  }

  // Financial calculations
  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => _currentRestaurant?.deliveryFee ?? 1.50;

  double get serviceFee => _items.isEmpty ? 0.0 : 0.50;

  double get discountAmount => subtotal * _discountPercent;

  double get total {
    if (isEmpty) return 0.0;
    final calculated = subtotal + deliveryFee + serviceFee - discountAmount;
    return calculated < 0 ? 0.0 : calculated;
  }

  // Coupon handling
  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'QUICK10') {
      _appliedCoupon = cleanCode;
      _discountPercent = 0.10; // 10%
      notifyListeners();
      return true;
    } else if (cleanCode == 'FOOD20') {
      _appliedCoupon = cleanCode;
      _discountPercent = 0.20; // 20%
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = '';
    _discountPercent = 0.0;
    notifyListeners();
  }
}
