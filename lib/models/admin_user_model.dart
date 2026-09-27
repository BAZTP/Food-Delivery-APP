enum AdminRole {
  superAdmin,
  orderManager,
  kitchenOperator,
  deliveryDispatcher;

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Administrador';
      case AdminRole.orderManager:
        return 'Gestor de Pedidos';
      case AdminRole.kitchenOperator:
        return 'Operador de Cocina';
      case AdminRole.deliveryDispatcher:
        return 'Despachador de Envíos';
    }
  }

  String get badgeColorHex {
    switch (this) {
      case AdminRole.superAdmin:
        return '#FF5A36';
      case AdminRole.orderManager:
        return '#3B82F6';
      case AdminRole.kitchenOperator:
        return '#10B981';
      case AdminRole.deliveryDispatcher:
        return '#F59E0B';
    }
  }
}

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  AdminUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
