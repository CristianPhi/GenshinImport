import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weapon.dart';

// Android emulator pakai 10.0.2.2, selain itu localhost
String get baseUrl {
  if (kIsWeb) return 'http://localhost:3007/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:3007/api';
  return 'http://localhost:3007/api';
}

class ApiService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'],
        'role': data['user']['role'],
        'userId': data['user']['id'],
      };
    }
    throw Exception('Login gagal');
  }

  static Future<List<Weapon>> getWeapons() async {
    final response = await http.get(Uri.parse('$baseUrl/weapons'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Weapon.fromJson(json)).toList();
    }
    throw Exception('Gagal load weapons');
  }

  static Future<List<dynamic>> getOrders(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw Exception('Gagal load orders');
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
    final response = await http.post(
      Uri.parse('$baseUrl/weapons'),
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

    if (response.statusCode != 201) {
      throw Exception('Gagal create weapon');
    }
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
    final response = await http.put(
      Uri.parse('$baseUrl/weapons/$id'),
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

    if (response.statusCode != 200) {
      throw Exception('Gagal update weapon');
    }
  }

  static Future<void> deleteWeapon(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/weapons/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal delete weapon');
    }
  }

  static Future<void> createOrder(
    String token,
    int weaponId,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'weapon_id': weaponId, 'quantity': quantity}),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal create order');
    }
  }
}
