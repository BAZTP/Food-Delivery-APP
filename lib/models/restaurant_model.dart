import 'food_item_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final String deliveryTime; // e.g. "20-30 min"
  final double deliveryFee; // 0.0 for free
  final String category; // e.g. "Hamburguesas", "Pizza"
  final String categoryId;
  final String bannerUrl;
  final String logoUrl;
  final String? promo; // e.g. "20% OFF en combos"
  final bool isFeatured;
  final bool isOpen;
  final double minimumOrder;
  final List<FoodItemModel> menu;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.category,
    required this.categoryId,
    required this.bannerUrl,
    required this.logoUrl,
    this.promo,
    this.isFeatured = false,
    this.isOpen = true,
    this.minimumOrder = 5.0,
    this.menu = const [],
  });

  bool get hasPromo => promo != null && promo!.isNotEmpty;
  bool get hasFreeDelivery => deliveryFee == 0.0;
}
