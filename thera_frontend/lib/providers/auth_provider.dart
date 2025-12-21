import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thera_frontend/models/user.dart';
import 'package:thera_frontend/services/user_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadToken() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        _token = token;
        _user = await _userService.getProfile(token);
        if (_user == null) {
          // Token exists but user load failed (e.g. backend restart)
          _token = null;
          await _storage.delete(key: 'jwt_token');
        }
      }
    } catch (e) {
      // Token invalid or network error, clear session
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _token = await _authService.login(email, password);
    if (_token != null) {
      await _storage.write(key: 'jwt_token', value: _token);
      _user = await _userService.getProfile(_token!);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _storage.delete(key: 'jwt_token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  bool get isAdmin => _user?.role == 'ADMIN';
}
