import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  String? _errorMessage;
  final List<AddressModel> _addresses = [];
  AddressModel _selectedAddress = const AddressModel(
    id: 'addr_pending',
    label: 'Sin dirección',
    street: 'Selecciona tu ubicación',
    number: '',
    city: '',
    isDefault: false,
  );
  bool get hasValidAddress => _selectedAddress.id != 'addr_pending';

  AuthProvider() {
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

  // Comprobar si un correo ya se encuentra registrado
  Future<bool> checkEmailExists(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return false;

    if (SupabaseConfig.isConfigured) {
      try {
        final res = await Supabase.instance.client
            .from('profiles')
            .select('id, email')
            .eq('email', cleanEmail)
            .maybeSingle();
        return res != null;
      } catch (e) {
        debugPrint('Comprobando existencia de correo: $e');
        return false;
      }
    }
    return false;
  }

  // Registro de nuevo usuario (sin requerir confirmación por correo)
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _errorMessage = null;
    final cleanEmail = email.trim().toLowerCase();

    if (SupabaseConfig.isConfigured) {
      try {
        // 1. Validar proactivamente en la tabla de perfiles si el correo ya existe
        final existsInProfiles = await checkEmailExists(cleanEmail);
        if (existsInProfiles) {
          _errorMessage = 'El correo "$cleanEmail" ya está registrado. Por favor inicia sesión o recupera tu contraseña.';
          notifyListeners();
          return false;
        }

        // 2. Ejecutar registro en Supabase Auth
        final response = await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {
            'full_name': name.trim(),
            'phone': phone.trim(),
          },
        );

        // Supabase oculta usuarios duplicados devolviendo un usuario con lista identities vacía
        if (response.user != null &&
            response.user!.identities != null &&
            response.user!.identities!.isEmpty) {
          _errorMessage = 'El correo "$cleanEmail" ya se encuentra registrado. Inicia sesión o recupera tu contraseña.';
          notifyListeners();
          return false;
        }

        if (response.user != null) {
          final user = response.user!;

          // Intentar iniciar sesión automáticamente para obtener sesión activa
          try {
            await Supabase.instance.client.auth.signInWithPassword(
              email: cleanEmail,
              password: password,
            );
          } catch (_) {
            // Si la confirmación por correo aún está activa en el proyecto de Supabase,
            // no bloqueamos al usuario y le permitimos entrar inmediatamente
          }

          _currentUser = UserModel(
            id: user.id,
            name: name.trim(),
            email: cleanEmail,
            phone: phone.trim(),
            defaultAddressId: _selectedAddress.id,
          );
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      } on AuthException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('already registered') ||
            msg.contains('already exists') ||
            msg.contains('user_already_exists')) {
          _errorMessage = 'El correo "$cleanEmail" ya está registrado. Inicia sesión o recupera tu contraseña.';
        } else {
          _errorMessage = e.message;
        }
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
        name: name.trim(),
        email: cleanEmail,
        phone: phone.trim(),
        defaultAddressId: _selectedAddress.id,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Restablecer contraseña directamente (sin requerir verificación de correo)
  Future<Map<String, dynamic>> resetPasswordDirectly({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (SupabaseConfig.isConfigured) {
      try {
        // Verificar si el correo existe
        final exists = await checkEmailExists(cleanEmail);
        if (!exists) {
          return {
            'success': false,
            'message': 'No existe ninguna cuenta registrada con el correo "$cleanEmail".',
          };
        }

        // Llamar a función RPC para actualizar contraseña en la base de datos
        final result = await Supabase.instance.client.rpc(
          'reset_user_password',
          params: {
            'user_email': cleanEmail,
            'new_password': newPassword,
          },
        );

        if (result == true) {
          return {
            'success': true,
            'message': '¡Tu contraseña ha sido restablecida exitosamente! Ya puedes iniciar sesión.',
          };
        }

        // Si la función RPC devuelve false o no existe, intentar enviar correo
        return await sendPasswordResetEmail(cleanEmail);
      } catch (e) {
        debugPrint('Error en reset_user_password RPC: $e');
        // Si no está instalada la función RPC, intentar con el método nativo de Supabase
        return await sendPasswordResetEmail(cleanEmail);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      return {
        'success': true,
        'message': '¡Contraseña restablecida correctamente en modo de prueba!',
      };
    }
  }

  // Enviar correo de restablecimiento vía Supabase Auth
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(cleanEmail);
      return {
        'success': true,
        'message': 'Se ha enviado un enlace de recuperación al correo "$cleanEmail". Revisa tu bandeja de entrada o spam.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': 'No se pudo enviar el correo de recuperación: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al intentar restablecer: $e',
      };
    }
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
