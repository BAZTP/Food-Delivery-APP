import 'dart:async';
import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/restaurant_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  OrderModel? _currentActiveOrder;
  Timer? _simulationTimer;

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

    // Start auto simulation of order progress
    _startOrderSimulation(newOrder.id);

    return newOrder;
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
  }

  // Simulate progress automatically every 8 seconds for a lively demo
  void _startOrderSimulation(String orderId) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) {
        timer.cancel();
        return;
      }

      final order = _orders[index];
      if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
        timer.cancel();
        return;
      }

      advanceOrderStatus(orderId);
    });
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = _orders[index].copyWith(status: OrderStatus.cancelled);
      _orders[index] = updated;
      if (_currentActiveOrder?.id == orderId) {
        _currentActiveOrder = updated;
      }
      _simulationTimer?.cancel();
      notifyListeners();
    }
  }

  void _initSampleOrders() {
    // Initial past order for history demonstration
    final sampleOrder = OrderModel(
      id: 'ORD-8921',
      userId: 'user_001',
      restaurantId: 'rest_burger_house',
      restaurantName: 'Burger House',
      restaurantBanner: 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=900&q=80',
      items: [
        CartItemModel(
          id: 'c1',
          foodItem: FoodItemModel(
            id: 'bh_01',
            restaurantId: 'rest_burger_house',
            name: 'Smash Bacon Supreme',
            description: 'Doble carne smash con queso cheddar y tocineta.',
            price: 9.50,
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
            categoryId: 'cat_burgers',
          ),
          quantity: 2,
        ),
      ],
      subtotal: 19.00,
      deliveryFee: 1.50,
      discount: 0.0,
      total: 21.00,
      address: const AddressModel(
        id: 'addr_1',
        label: 'Casa',
        street: 'Av. Las Palmas',
        number: '45-12 Apt 402',
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

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
