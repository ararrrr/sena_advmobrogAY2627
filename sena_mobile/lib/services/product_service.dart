import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final apiHost = host;
    if (apiHost == null || apiHost.isEmpty) {
      throw StateError('HOST is not configured in assets/.env');
    }

    final response = await http.get(Uri.parse('$apiHost/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'] ?? [];

      return productsJson
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Failed to load products (status ${response.statusCode})',
    );
  }

  Future<Product> getProductById(int productId) async {
    final apiHost = host;
    if (apiHost == null || apiHost.isEmpty) {
      throw StateError('HOST is not configured in assets/.env');
    }

    final response = await http.get(Uri.parse('$apiHost/products/$productId'));

    if (response.statusCode == 200) {
      return Product.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load product (status ${response.statusCode})',
    );
  }
}
