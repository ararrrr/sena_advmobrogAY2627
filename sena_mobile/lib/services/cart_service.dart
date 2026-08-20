import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<List<Cart>> getAllCarts() async {
    final apiHost = host;
    if (apiHost == null || apiHost.isEmpty) {
      throw StateError('HOST is not configured in assets/.env');
    }

    final response = await http.get(Uri.parse('$apiHost/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> cartsJson = data['carts'] ?? [];

      return cartsJson
          .map(
            (json) => Cart.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    }

    throw Exception('Failed to load carts (status ${response.statusCode})');
  }

  // Enhancement 3: Load only the carts that belong to one user.
  Future<Cart?> getCartByUser(int userId) async {
    final apiHost = _requireHost();
    final response = await http.get(Uri.parse('$apiHost/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> cartsJson = data['carts'] ?? [];

      if (cartsJson.isEmpty) return null;
      return Cart.fromJson(
        Map<String, dynamic>.from(cartsJson.first as Map),
      );
    }

    throw Exception(
      'Failed to load the user cart (status ${response.statusCode})',
    );
  }

  // Enhancement 3: Send a product and quantity to the add-cart endpoint.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final apiHost = _requireHost();
    final response = await http.post(
      Uri.parse('$apiHost/carts/add'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Cart.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to add cart (status ${response.statusCode})');
  }

  String _requireHost() {
    final apiHost = host;
    if (apiHost == null || apiHost.isEmpty) {
      throw StateError('HOST is not configured in assets/.env');
    }
    return apiHost;
  }
}
