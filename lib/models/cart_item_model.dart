import 'food_item_model.dart';

enum PizzaSize {
  personal,
  mediana,
  grande,
}

extension PizzaSizeExtension on PizzaSize {
  String get displayName {
    switch (this) {
      case PizzaSize.personal:
        return 'Personal';
      case PizzaSize.mediana:
        return 'Mediana';
      case PizzaSize.grande:
        return 'Grande';
    }
  }

  String get emoji {
    switch (this) {
      case PizzaSize.personal:
        return '🍕';
      case PizzaSize.mediana:
        return '🍕🍕';
      case PizzaSize.grande:
        return '🍕🍕🍕';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case PizzaSize.personal:
        return 0.75;
      case PizzaSize.mediana:
        return 1.0;
      case PizzaSize.grande:
        return 1.35;
    }
  }
}

class CartItemModel {
  final String id;
  final FoodItemModel foodItem;
  int quantity;
  final String specialInstructions;
  final PizzaSize? pizzaSize;

  CartItemModel({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
    this.specialInstructions = '',
    this.pizzaSize,
  });

  double get unitPrice {
    if (pizzaSize != null) {
      return double.parse((foodItem.price * pizzaSize!.priceMultiplier).toStringAsFixed(2));
    }
    return foodItem.price;
  }

  double get totalPrice => unitPrice * quantity;

  String get sizeLabel => pizzaSize?.displayName ?? '';

  CartItemModel copyWith({
    String? id,
    FoodItemModel? foodItem,
    int? quantity,
    String? specialInstructions,
    PizzaSize? pizzaSize,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      pizzaSize: pizzaSize ?? this.pizzaSize,
    );
  }
}
