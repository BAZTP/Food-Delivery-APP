import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  String? _errorMessage;
  final List<AddressModel> _addresses = [
    const AddressModel(
      id: 'addr_default',
      label: 'Casa',
      street: 'Calle Principal',
      number: '123',
      reference: 'Frente al parque central',
      city: 'Quito',
      isDefault: true,
    ),
    const AddressModel(
      id: 'addr_work',
      label: 'Trabajo',
      street: 'Av. Amazonas',
      number: '456',
      reference: 'Piso 4, Oficina 402',
      city: 'Quito',
      isDefault: false,
    ),
  ];
  late AddressModel _selectedAddress;

  AuthProvider() {
    _selectedAddress = _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
    _checkInitialSession();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
  String? get errorMessage => _errorMessage;
  List<AddressModel> get addresses => _addresses;
  AddressModel get selectedAddress => _selectedAddress;

  void _checkInitialSession() {
    if (SupabaseConfig.isConfigured) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && session.user.email != null) {
          final user = session.user;
          _currentUser = UserModel(
            id: user.id,
            name: user.userMetadata?['full_name'] ?? user.email!.split('@').first,
            email: user.email!,
            phone: user.userMetadata?['phone'] ?? '',
            defaultAddressId: _selectedAddress.id,
          );
          _isAuthenticated = true;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error comprobando sesión inicial: $e');
      }
    }
  }

  // Selección de dirección de entrega
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress({
    required String label,
    required String street,
    required String number,
    String reference = '',
    String city = 'Quito',
    bool selectAsCurrent = true,
  }) {
    final newAddress = AddressModel(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      street: street,
      number: number,
      reference: reference,
      city: city,
      isDefault: selectAsCurrent || _addresses.isEmpty,
    );
    _addresses.insert(0, newAddress);
    if (selectAsCurrent) {
      _selectedAddress = newAddress;
    }
    notifyListeners();
  }

  void updateLocationDirectly({
    required String label,
    required String street,
    String number = '',
    String reference = '',
    String city = 'Quito',
  }) {
    final newAddress = AddressModel(
      id: 'addr_gps_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      street: street,
      number: number,
      reference: reference,
      city: city,
      isDefault: true,
    );
    _addresses.insert(0, newAddress);
    _selectedAddress = newAddress;
    notifyListeners();
  }

  void removeAddress(String id) {
    if (_addresses.length <= 1) return;
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddress.id == id) {
      _selectedAddress = _addresses.first;
    }
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }

  // Inicio de Sesión
  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          final user = response.user!;
          _currentUser = UserModel(
            id: user.id,
            name: user.userMetadata?['full_name'] ?? email.split('@').first,
            email: user.email ?? email,
            phone: user.userMetadata?['phone'] ?? '',
            defaultAddressId: _selectedAddress.id,
          );
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      } on AuthException catch (e) {
        _errorMessage = e.message;
        notifyListeners();
        return false;
      } catch (e) {
        _errorMessage = 'Error de conexión con la base de datos: $e';
        notifyListeners();
        return false;
      }
    } else {
      // Modo local si aún no se configuran las llaves de Supabase
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first.toUpperCase(),
        email: email,
        phone: '+593 99 123 4567',
        defaultAddressId: _selectedAddress.id,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Registro de nuevo usuario
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _errorMessage = null;

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': name,
            'phone': phone,
          },
        );

        if (response.user != null) {
          final user = response.user!;
          _currentUser = UserModel(
            id: user.id,
            name: name,
            email: user.email ?? email,
            phone: phone,
            defaultAddressId: _selectedAddress.id,
          );
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      } on AuthException catch (e) {
        _errorMessage = e.message;
        notifyListeners();
        return false;
      } catch (e) {
        _errorMessage = 'Error al registrar usuario: $e';
        notifyListeners();
        return false;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        defaultAddressId: _selectedAddress.id,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Cerrar Sesión
  Future<void> logout() async {
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Error cerrando sesión en Supabase: $e');
      }
    }
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
