import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const int _userId = 5;

  late final Future<Cart?> _cartFuture;
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    // Enhancement 3: Render only the cart belonging to user ID 5.
    _cartFuture = CartService().getCartByUser(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: CustomText(
                  text: 'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) {
            return const Center(child: Text('The cart is empty.'));
          }

          for (final item in cart.products) {
            _quantities.putIfAbsent(item.id, () => item.quantity);
          }

          final subtotal = _calculateSubtotal(cart.products);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
                  itemCount: cart.products.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    return _buildCartItem(cart.products[index]);
                  },
                ),
              ),
              _buildOrderSummary(subtotal),
            ],
          );
        },
      ),
    );
  }

  // Enhancement 1: Each cart card opens the shared product details screen.
  Widget _buildCartItem(CartProduct item) {
    final quantity = _quantities[item.id] ?? item.quantity;
    final originalTotal = item.price * quantity;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: InkWell(
        onTap: () => _openProductDetails(item),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: Image.network(
                  item.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: item.title,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    CustomText(
                      text: '\$${item.price.toStringAsFixed(2)}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 3.h),
                    CustomText(
                      text:
                          '${item.discountPercentage.toStringAsFixed(0)}% off • '
                          '\$${originalTotal.toStringAsFixed(2)} total',
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                children: [
                  _quantityButton(
                    icon: Icons.add,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    onPressed: () => _changeQuantity(item, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: CustomText(
                      text: '$quantity',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.remove,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    onPressed: quantity > 1
                        ? () => _changeQuantity(item, -1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox.square(
      dimension: 32.r,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(9.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(9.r),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 18.r,
            color: onPressed == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal:', subtotal),
          SizedBox(height: 6.h),
          _summaryRow('Delivery Fee:', 0),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: _confirmOrder,
              child: const Text(
                'Confirm Order',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: label, color: Colors.grey),
        CustomText(
          text: '\$${amount.toStringAsFixed(2)}',
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  double _calculateSubtotal(List<CartProduct> products) {
    return products.fold(0, (sum, item) {
      final quantity = _quantities[item.id] ?? item.quantity;
      final discountedUnitPrice = item.quantity == 0
          ? item.price
          : item.discountedTotal / item.quantity;
      return sum + (discountedUnitPrice * quantity);
    });
  }

  void _changeQuantity(CartProduct item, int change) {
    final current = _quantities[item.id] ?? item.quantity;
    final next = current + change;
    if (next < 1) return;
    setState(() => _quantities[item.id] = next);
  }

  void _confirmOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmed.')),
    );
  }

  Future<void> _openProductDetails(CartProduct item) async {
    try {
      final product = await ProductService().getProductById(item.id);
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(product: product),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open product: $error')),
      );
    }
  }
}
