import 'food_item_model.dart';

class CartItemModel {
  final String id;
  final FoodItemModel foodItem;
  int quantity;
  final String specialInstructions;

  CartItemModel({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
    this.specialInstructions = '',
  });

  double get totalPrice => foodItem.price * quantity;

  CartItemModel copyWith({
    String? id,
    FoodItemModel? foodItem,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
