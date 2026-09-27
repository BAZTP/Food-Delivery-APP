import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser = MockData.currentUser;
  bool _isAuthenticated = true;
  final List<AddressModel> _addresses = List.from(MockData.initialAddresses);
  late AddressModel _selectedAddress;

  AuthProvider() {
    _selectedAddress = _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
  List<AddressModel> get addresses => _addresses;
  AddressModel get selectedAddress => _selectedAddress;

  // Set default / current delivery address
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress({
    required String label,
    required String street,
    required String number,
    String reference = '',
    String city = 'Ciudad',
  }) {
    final newAddress = AddressModel(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      street: street,
      number: number,
      reference: reference,
      city: city,
      isDefault: _addresses.isEmpty,
    );
    _addresses.add(newAddress);
    if (_addresses.length == 1) {
      _selectedAddress = newAddress;
    }
    notifyListeners();
  }

  void removeAddress(String id) {
    if (_addresses.length <= 1) return; // Keep at least one
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddress.id == id) {
      _selectedAddress = _addresses.first;
    }
    notifyListeners();
  }

  // Update profile
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

  // Login
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simula red
    _currentUser = UserModel(
      id: 'user_001',
      name: email.split('@').first.toUpperCase(),
      email: email,
      phone: '+57 310 492 8173',
      defaultAddressId: _selectedAddress.id,
    );
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // Quick Demo Login
  void loginDemo() {
    _currentUser = MockData.currentUser;
    _isAuthenticated = true;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      defaultAddressId: _selectedAddress.id,
    );
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // Logout
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
