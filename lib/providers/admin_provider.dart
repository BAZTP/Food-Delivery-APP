import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
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

  AdminProvider() {
    _loadAdminUsersFromSupabase();
  }

  AdminUserModel? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _isAuthenticated && _currentAdmin != null;
  List<AdminUserModel> get adminUsers => List.unmodifiable(_adminUsers);

  AdminRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'superAdmin':
        return AdminRole.superAdmin;
      case 'deliveryDispatcher':
        return AdminRole.deliveryDispatcher;
      case 'kitchenOperator':
        return AdminRole.kitchenOperator;
      case 'orderManager':
      default:
        return AdminRole.orderManager;
    }
  }

  // Carga remota de operadores desde Supabase (si existe la tabla)
  Future<void> _loadAdminUsersFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('admin_users').select();
      if (data.isNotEmpty) {
        _adminUsers.clear();
        for (final row in data) {
          _adminUsers.add(AdminUserModel(
            id: row['id']?.toString() ?? 'adm_${DateTime.now().millisecondsSinceEpoch}',
            name: row['name']?.toString() ?? 'Operador',
            email: row['email']?.toString() ?? '',
            phone: row['phone']?.toString() ?? '',
            role: _parseRole(row['role']?.toString()),
            isActive: row['is_active'] == true,
            createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Nota CRM: usando lista local de operadores: $e');
    }
  }

  // Iniciar sesión de Administrador
  Future<bool> loginAdmin(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    // 1. Intentar validar con Supabase primero si está configurado
    if (SupabaseConfig.isConfigured) {
      try {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('admin_users')
            .select()
            .eq('email', normalizedEmail)
            .maybeSingle();

        if (response != null && response['is_active'] == true) {
          _currentAdmin = AdminUserModel(
            id: response['id'].toString(),
            name: response['name'].toString(),
            email: response['email'].toString(),
            phone: response['phone']?.toString() ?? '',
            role: _parseRole(response['role']?.toString()),
            isActive: true,
            createdAt: DateTime.tryParse(response['created_at']?.toString() ?? '') ?? DateTime.now(),
          );
          _isAuthenticated = true;
          _loadAdminUsersFromSupabase();
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Nota CRM Supabase login: $e');
      }
    }

    // 2. Validación local con lista o credencial maestra
    await Future.delayed(const Duration(milliseconds: 300));
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

    if (SupabaseConfig.isConfigured) {
      _saveAdminUserToSupabase(newUser);
    }
  }

  Future<void> _saveAdminUserToSupabase(AdminUserModel user) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('admin_users').insert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.name,
        'is_active': user.isActive,
      });
    } catch (e) {
      debugPrint('Nota CRM: guardando operador local: $e');
    }
  }

  // Activar o desactivar operador
  void toggleUserStatus(String id) {
    final index = _adminUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      final current = _adminUsers[index];
      if (current.id == 'adm_001') return; // Proteger superadmin
      final updated = current.copyWith(isActive: !current.isActive);
      _adminUsers[index] = updated;
      notifyListeners();

      if (SupabaseConfig.isConfigured) {
        _updateAdminStatusInSupabase(id, updated.isActive);
      }
    }
  }

  Future<void> _updateAdminStatusInSupabase(String id, bool isActive) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('admin_users').update({'is_active': isActive}).eq('id', id);
    } catch (e) {
      debugPrint('Nota CRM: actualización local de estado: $e');
    }
  }

  // Cambiar rol de usuario
  void updateRole(String id, AdminRole newRole) {
    final index = _adminUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      _adminUsers[index] = _adminUsers[index].copyWith(role: newRole);
      notifyListeners();

      if (SupabaseConfig.isConfigured) {
        _updateAdminRoleInSupabase(id, newRole.name);
      }
    }
  }

  Future<void> _updateAdminRoleInSupabase(String id, String roleName) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('admin_users').update({'role': roleName}).eq('id', id);
    } catch (e) {
      debugPrint('Nota CRM: actualización local de rol: $e');
    }
  }

  // Eliminar usuario de control
  void deleteUser(String id) {
    if (id == 'adm_001') return;
    _adminUsers.removeWhere((u) => u.id == id);
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      _deleteAdminUserFromSupabase(id);
    }
  }

  Future<void> _deleteAdminUserFromSupabase(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('admin_users').delete().eq('id', id);
    } catch (e) {
      debugPrint('Nota CRM: eliminación local: $e');
    }
  }
}
