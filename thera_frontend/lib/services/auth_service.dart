import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thera_frontend/config/api_config.dart';

class AuthService {
  /// LOGIN
  Future<String?> login(String email, String password) async {
    print('AuthService: Logging in $email'); // DEBUG
    final url = Uri.parse(ApiConfig.login);
    print('AuthService: POST $url'); // DEBUG

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('AuthService: Response ${response.statusCode}'); // DEBUG
      print('AuthService: Body ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        print('AuthService: Login failed with status ${response.statusCode}'); // DEBUG
      }
    } catch (e) {
      print('AuthService: Login error: $e'); // DEBUG
    }
    return null;
  }

  /// REGISTER
  Future<bool> register(
      String username, String email, String password, String role) async {
    print('AuthService: Registering $username ($email) as $role'); // DEBUG
    final url = Uri.parse(ApiConfig.register);
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print('AuthService: Register Reponse ${response.statusCode}'); // DEBUG
      print('AuthService: Register Body ${response.body}'); // DEBUG

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('AuthService: Register error: $e'); // DEBUG
      rethrow;
    }
  }
}
