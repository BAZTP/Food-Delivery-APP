import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';

class AdminProvider extends ChangeNotifier {
  AdminUserModel? _currentAdmin;
  bool _isAuthenticated = false;

  final List<AdminUserModel> _adminUsers = [
    AdminUserModel(
      id: 'adm_001',
      name: 'Bryan Zambrano',
      email: 'admin@quickfood.com',
      phone: '+593 99 876 5432',
      role: AdminRole.superAdmin,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AdminUserModel(
      id: 'adm_002',
      name: 'Carlos Mendoza',
      email: 'carlos.despacho@quickfood.com',
      phone: '+593 98 765 4321',
      role: AdminRole.deliveryDispatcher,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    AdminUserModel(
      id: 'adm_003',
      name: 'María Elena Torres',
      email: 'maria.cocina@quickfood.com',
      phone: '+593 97 654 3210',
      role: AdminRole.kitchenOperator,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    AdminUserModel(
      id: 'adm_004',
      name: 'Andrés Gómez',
      email: 'andres.pedidos@quickfood.com',
      phone: '+593 96 543 2109',
      role: AdminRole.orderManager,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  AdminUserModel? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _isAuthenticated && _currentAdmin != null;
  List<AdminUserModel> get adminUsers => List.unmodifiable(_adminUsers);

  // Iniciar sesión de Administrador
  Future<bool> loginAdmin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    
    // Validar con la lista de admins o credenciales maestras
    final found = _adminUsers.firstWhere(
      (u) => u.email.toLowerCase() == normalizedEmail && u.isActive,
      orElse: () {
        if (normalizedEmail == 'admin@quickfood.com' || normalizedEmail.contains('admin')) {
          return _adminUsers.first;
        }
        return AdminUserModel(
          id: 'adm_temp',
          name: '',
          email: '',
          phone: '',
          role: AdminRole.orderManager,
          isActive: false,
          createdAt: DateTime.now(),
        );
      },
    );

    if (found.id != 'adm_temp' && found.isActive) {
      _currentAdmin = found;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  // Cerrar Sesión Administrador
  void logoutAdmin() {
    _currentAdmin = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Agregar nuevo usuario de control / operador
  void addAdminUser({
    required String name,
    required String email,
    required String phone,
    required AdminRole role,
  }) {
    final newUser = AdminUserModel(
      id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
    );
    _adminUsers.insert(0, newUser);
    notifyListeners();
  }

  // Activar o desactivar operador
  void toggleUserStatus(String id) {
    final index = _adminUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      final current = _adminUsers[index];
      // No permitir desactivar al superAdmin principal
      if (current.id == 'adm_001') return;
      _adminUsers[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  // Cambiar rol de usuario
  void updateRole(String id, AdminRole newRole) {
    final index = _adminUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      _adminUsers[index] = _adminUsers[index].copyWith(role: newRole);
      notifyListeners();
    }
  }

  // Eliminar usuario de control
  void deleteUser(String id) {
    if (id == 'adm_001') return; // Proteger superadmin
    _adminUsers.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
