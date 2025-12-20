import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class UserService {
  Future<User?> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> updateProfile(
    String token,
    String username,
    String email,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'email': email}),
    );

    return response.statusCode == 200;
  }
}
