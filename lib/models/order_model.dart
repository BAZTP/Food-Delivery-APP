import 'address_model.dart';
import 'cart_item_model.dart';
import 'payment_method_model.dart';

enum OrderStatus {
  received,   // 1. Pedido recibido
  preparing,  // 2. Restaurante preparando
  pickup,     // 3. Repartidor recogiendo
  onTheWay,   // 4. En camino
  delivered,  // 5. Entregado
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.received:
        return 'Pedido recibido';
      case OrderStatus.preparing:
        return 'Restaurante preparando';
      case OrderStatus.pickup:
        return 'Repartidor recogiendo';
      case OrderStatus.onTheWay:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.received:
        return 'El restaurante ha recibido tu orden y la confirmará pronto.';
      case OrderStatus.preparing:
        return 'El chef está cocinando tus deliciosos platillos.';
      case OrderStatus.pickup:
        return 'El repartidor está esperando tu pedido en el restaurante.';
      case OrderStatus.onTheWay:
        return 'Tu repartidor va velozmente en dirección a tu ubicación.';
      case OrderStatus.delivered:
        return '¡Buen provecho! Tu comida ha sido entregada con éxito.';
      case OrderStatus.cancelled:
        return 'El pedido ha sido cancelado.';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.received:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.pickup:
        return 2;
      case OrderStatus.onTheWay:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isActive => this != OrderStatus.delivered && this != OrderStatus.cancelled;
}

class TrackingStep {
  final OrderStatus status;
  final String title;
  final String description;
  final DateTime? time;
  final bool isCompleted;
  final bool isCurrent;

  const TrackingStep({
    required this.status,
    required this.title,
    required this.description,
    this.time,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String restaurantBanner;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final AddressModel address;
  final PaymentMethodModel paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final String estimatedDeliveryTime;
  final String driverName;
  final String driverPhone;
  final double driverRating;
  final String driverVehicle;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantBanner,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0.0,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.estimatedDeliveryTime,
    this.driverName = 'Carlos Mendoza',
    this.driverPhone = '+57 301 555 0192',
    this.driverRating = 4.9,
    this.driverVehicle = 'Moto Honda CB160 • ABC-123',
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    String? restaurantBanner,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    AddressModel? address,
    PaymentMethodModel? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    String? estimatedDeliveryTime,
    String? driverName,
    String? driverPhone,
    double? driverRating,
    String? driverVehicle,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantBanner: restaurantBanner ?? this.restaurantBanner,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
    );
  }
}
