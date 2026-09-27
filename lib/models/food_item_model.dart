class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final int preparationMinutes;
  final String calories;

  const FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.rating = 4.8,
    this.reviewCount = 50,
    this.isPopular = false,
    this.preparationMinutes = 20,
    this.calories = '',
  });
}
