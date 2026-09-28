import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/restaurant_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  OrderModel? _currentActiveOrder;

  OrderProvider() {
    _initSampleOrders();
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  OrderModel? get currentActiveOrder => _currentActiveOrder;

  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList();

  List<OrderModel> get pastOrders =>
      _orders.where((o) => !o.status.isActive).toList();

  // Create order
  OrderModel placeOrder({
    required String userId,
    required RestaurantModel restaurant,
    required List<CartItemModel> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    required AddressModel address,
    required PaymentMethodModel paymentMethod,
  }) {
    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: userId,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantBanner: restaurant.bannerUrl,
      items: List.from(items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.received,
      createdAt: DateTime.now(),
      estimatedDeliveryTime: restaurant.deliveryTime,
      driverName: 'Carlos Mendoza',
      driverPhone: '+57 301 555 0192',
      driverRating: 4.9,
      driverVehicle: 'Moto Honda CB160 • ABC-123',
    );

    _orders.insert(0, newOrder);
    _currentActiveOrder = newOrder;
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      _saveOrderToSupabase(newOrder);
    }

    return newOrder;
  }

  Future<void> _saveOrderToSupabase(OrderModel order) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('orders').insert({
        'id': order.id,
        'user_id': (order.userId.startsWith('usr_') || order.userId.startsWith('user_')) ? null : order.userId,
        'restaurant_id': order.restaurantId,
        'restaurant_name': order.restaurantName,
        'status': order.status.name,
        'subtotal': order.subtotal,
        'delivery_fee': order.deliveryFee,
        'service_fee': 1.00,
        'discount': order.discount,
        'total': order.total,
        'delivery_address': order.address.fullAddress,
        'payment_method': order.paymentMethod.title,
        'driver_name': order.driverName,
        'driver_phone': order.driverPhone,
      });

      for (final item in order.items) {
        await supabase.from('order_items').insert({
          'order_id': order.id,
          'food_item_id': item.foodItem.id,
          'food_item_name': '${item.foodItem.name}${item.sizeLabel.isNotEmpty ? ' (${item.sizeLabel})' : ''}',
          'food_item_price': item.unitPrice,
          'food_item_image': item.foodItem.imageUrl,
          'quantity': item.quantity,
          'special_instructions': item.specialInstructions,
        });
      }
    } catch (e) {
      debugPrint('Nota: Guardado de orden en Supabase: $e');
    }
  }

  void setActiveOrder(OrderModel order) {
    _currentActiveOrder = order;
    notifyListeners();
  }

  // Advance order status manually or programmatically
  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final current = _orders[index];
    OrderStatus nextStatus;

    switch (current.status) {
      case OrderStatus.received:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.pickup;
        break;
      case OrderStatus.pickup:
        nextStatus = OrderStatus.onTheWay;
        break;
      case OrderStatus.onTheWay:
        nextStatus = OrderStatus.delivered;
        break;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return;
    }

    final updated = current.copyWith(status: nextStatus);
    _orders[index] = updated;

    if (_currentActiveOrder?.id == orderId) {
      _currentActiveOrder = updated;
    }

    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      _updateOrderStatusInSupabase(orderId, nextStatus.name);
    }
  }

  Future<void> _updateOrderStatusInSupabase(String orderId, String status) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('orders').update({'status': status}).eq('id', orderId);
    } catch (e) {
      debugPrint('Nota Supabase actualización pedido: $e');
    }
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = _orders[index].copyWith(status: OrderStatus.cancelled);
      _orders[index] = updated;
      if (_currentActiveOrder?.id == orderId) {
        _currentActiveOrder = updated;
      }
      notifyListeners();

      if (SupabaseConfig.isConfigured) {
        _updateOrderStatusInSupabase(orderId, 'cancelled');
      }
    }
  }

  void _initSampleOrders() {
    // Initial past order for history demonstration
    final sampleOrder = OrderModel(
      id: 'ORD-8921',
      userId: 'user_001',
      restaurantId: 'rest_pizza_express',
      restaurantName: 'Napoli Pizza Artesanal',
      restaurantBanner: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
      items: [
        CartItemModel(
          id: 'c1',
          foodItem: const FoodItemModel(
            id: 'pz_01',
            restaurantId: 'rest_pizza_express',
            name: 'Pizza Pepperoni Supremo',
            description: 'Masa madre horneada a la piedra, pomodoro y mozzarella fior di latte.',
            price: 13.90,
            imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=600&q=80',
            categoryId: 'cat_tradicionales',
          ),
          quantity: 1,
        ),
        CartItemModel(
          id: 'c2',
          foodItem: const FoodItemModel(
            id: 'pz_15',
            restaurantId: 'rest_pizza_express',
            name: 'Palitroques con Ajo & Mozzarella',
            description: 'Tiras de masa madre con mantequilla de ajo y dip pomodoro.',
            price: 5.50,
            imageUrl: 'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?auto=format&fit=crop&w=600&q=80',
            categoryId: 'cat_entradas',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 19.40,
      deliveryFee: 0.0,
      discount: 0.0,
      total: 19.40,
      address: const AddressModel(
        id: 'addr_1',
        label: 'Casa',
        street: 'Av. Las Palmas',
        number: '45-12 Apt 402',
        city: 'Quito',
      ),
      paymentMethod: const PaymentMethodModel(
        id: 'pay_card',
        type: PaymentType.card,
        title: 'Tarjeta de Crédito',
        subtitle: '•••• 4589',
        icon: Icons.credit_card_rounded,
      ),
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      estimatedDeliveryTime: 'Entregado',
    );

    _orders.add(sampleOrder);
  }
}
