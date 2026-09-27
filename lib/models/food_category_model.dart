class FoodCategoryModel {
  final String id;
  final String name;
  final String icon; // Emoji or asset name
  final String description;

  const FoodCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
  });
}
