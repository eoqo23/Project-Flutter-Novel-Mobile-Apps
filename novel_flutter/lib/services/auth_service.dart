import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // 🔥 GLOBAL STATE
  static String? token;
  static String? role;

  // 🔐 LOGIN
  static Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ SIMPAN TOKEN & ROLE
      token = data['token'];
      role = data['user']['role']; // pastikan backend kirim ini

      return User.fromJson(data['user']);
    } else {
      return null;
    }
  }

  // 🔐 GET TOKEN
  static String? getToken() => token;

  // 🔐 ROLE CHECK
  static bool isAuthor() => role == 'author';
  static bool isAdmin() => role == 'admin';
  static bool isUser() => role == 'user';

  // 🔓 LOGOUT
  static void logout() {
    token = null;
    role = null;
  }
}