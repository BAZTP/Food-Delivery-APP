import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'custom_network_image.dart';

class FoodItemDetailSheet extends StatefulWidget {
  final FoodItemModel foodItem;
  final RestaurantModel restaurant;

  const FoodItemDetailSheet({
    super.key,
    required this.foodItem,
    required this.restaurant,
  });

  static Future<void> show(
    BuildContext context, {
    required FoodItemModel foodItem,
    required RestaurantModel restaurant,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodItemDetailSheet(
        foodItem: foodItem,
        restaurant: restaurant,
      ),
    );
  }

  @override
  State<FoodItemDetailSheet> createState() => _FoodItemDetailSheetState();
}

class _FoodItemDetailSheetState extends State<FoodItemDetailSheet> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onAddToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = cartProvider.addItem(
      widget.foodItem,
      widget.restaurant,
      quantity: _quantity,
      specialInstructions: _notesController.text.trim(),
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Se agregó ${widget.foodItem.name} a tu carrito!'),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: AppColors.primary,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } else {
      // Different restaurant prompt
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Iniciar nuevo pedido?'),
          content: Text(
            'Tu carrito contiene productos de "${cartProvider.currentRestaurant?.name}". ¿Deseas vaciar el carrito y comenzar un nuevo pedido con "${widget.restaurant.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                cartProvider.forceAddItem(
                  widget.foodItem,
                  widget.restaurant,
                  quantity: _quantity,
                  specialInstructions: _notesController.text.trim(),
                );
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Carrito reiniciado con ${widget.foodItem.name}'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Comenzar nuevo'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.foodItem.price * _quantity;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Dish Image
            Stack(
              children: [
                CustomNetworkImage(
                  imageUrl: widget.foodItem.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodItem.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.foodItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating & Prep Time
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.foodItem.rating} (${widget.foodItem.reviewCount})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '~${widget.foodItem.preparationMinutes} min',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (widget.foodItem.calories.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.foodItem.calories,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.foodItem.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Special notes input
                  const Text(
                    'Instrucciones especiales',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Sin mayonesa, salsa extra picante, cubiertos descartables...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity and Add to Cart Action
                  Row(
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onAddToCart(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Agregar • \$${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
