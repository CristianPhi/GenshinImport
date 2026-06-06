import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/weapon.dart';

const Duration apiTimeout = Duration(seconds: 15);

class ApiService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<http.Response> _post(String path, {Map<String, String>? headers, Object? body}) {
    return http
        .post(Uri.parse('$_baseUrl$path'), headers: headers, body: body)
        .timeout(apiTimeout);
  }

  static Future<http.Response> _get(String path, {Map<String, String>? headers}) {
    return http.get(Uri.parse('$_baseUrl$path'), headers: headers).timeout(apiTimeout);
  }

  static Future<http.Response> _put(String path, {Map<String, String>? headers, Object? body}) {
    return http
        .put(Uri.parse('$_baseUrl$path'), headers: headers, body: body)
        .timeout(apiTimeout);
  }

  static Future<http.Response> _delete(String path, {Map<String, String>? headers}) {
    return http.delete(Uri.parse('$_baseUrl$path'), headers: headers).timeout(apiTimeout);
  }

  static Exception _connectionError() {
    if (ApiConfig.useLocal) {
      return Exception(
        'Backend lokal tidak bisa dihubungi.\n'
        'Jalankan: cd backend && npm run dev',
      );
    }
    return Exception(
      'Backend Railway tidak bisa dihubungi.\n'
      'Cek URL di lib/config/api_config.dart\n'
      'Pastikan service di Railway sudah Running.',
    );
  }

  static Map<String, dynamic> _parseAuthResponse(http.Response response) {
    final data = jsonDecode(response.body);
    return {
      'token': data['token'],
      'role': data['user']['role'],
      'userId': data['user']['id'],
    };
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _post(
        '/auth/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) return _parseAuthResponse(response);
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Register gagal');
    } on SocketException {
      throw _connectionError();
    } on TimeoutException {
      throw _connectionError();
    } on http.ClientException {
      throw _connectionError();
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _post(
        '/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) return _parseAuthResponse(response);
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Login gagal');
    } on SocketException {
      throw _connectionError();
    } on TimeoutException {
      throw _connectionError();
    } on http.ClientException {
      throw _connectionError();
    }
  }

  static Future<List<Weapon>> getWeapons() async {
    try {
      final response = await _get('/weapons');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Weapon.fromJson(json)).toList();
      }
      throw Exception('Gagal load weapons');
    } on SocketException {
      throw _connectionError();
    } on TimeoutException {
      throw _connectionError();
    }
  }

  static Future<List<dynamic>> getOrders(String token, int userId) async {
    try {
      final response = await _get(
        '/orders/user/$userId',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      }
      throw Exception('Gagal load orders');
    } on SocketException {
      throw _connectionError();
    } on TimeoutException {
      throw _connectionError();
    }
  }

  static Future<void> createWeapon({
    required String token,
    required String name,
    required String type,
    required String description,
    required int stock,
    required double price,
    String? imageUrl,
  }) async {
    final response = await _post(
      '/weapons',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'description': description,
        'stock': stock,
        'price': price,
        'image': imageUrl,
      }),
    );
    if (response.statusCode != 201) throw Exception('Gagal create weapon');
  }

  static Future<void> updateWeapon(
    String token,
    int id, {
    required String name,
    required String type,
    required String description,
    required int stock,
    required double price,
    String? imageUrl,
  }) async {
    final response = await _put(
      '/weapons/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'description': description,
        'stock': stock,
        'price': price,
        'image': imageUrl,
      }),
    );
    if (response.statusCode != 200) throw Exception('Gagal update weapon');
  }

  static Future<void> deleteWeapon(String token, int id) async {
    final response = await _delete(
      '/weapons/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Gagal delete weapon');
  }

  static Future<void> createOrder(String token, int weaponId, int quantity) async {
    final response = await _post(
      '/orders',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'weapon_id': weaponId, 'quantity': quantity}),
    );
    if (response.statusCode != 201) throw Exception('Gagal create order');
  }
}
