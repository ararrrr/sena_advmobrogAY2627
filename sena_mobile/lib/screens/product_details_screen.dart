import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  product.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported, size: 64.sp),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomText(
              text: product.title,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CustomText(
                  text: '\$${product.price.toStringAsFixed(2)}',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Chip(
                  avatar: const Icon(Icons.star, color: Colors.amber),
                  label: Text(product.rating.toStringAsFixed(1)),
                ),
                Chip(label: Text('${product.stock} in stock')),
              ],
            ),
            SizedBox(height: 16.h),
            _DetailRow(label: 'Category', value: product.category),
            if (product.brand.isNotEmpty)
              _DetailRow(label: 'Brand', value: product.brand),
            _DetailRow(label: 'Availability', value: product.availabilityStatus),
            SizedBox(height: 12.h),
            CustomText(
              text: 'Description',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: product.description,
              fontSize: 14.sp,
              letterSpacing: 0.2,
            ),
            if (product.tags.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                children: product.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
            SizedBox(height: 20.h),
            // Enhancement 3: Pass the selected product to /carts/add.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? SizedBox.square(
                        dimension: 18.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(
                  _isAddingToCart ? 'Adding...' : 'Add to Cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);

    try {
      final user = await UserService().getUser();
      final cart = await CartService().addToCart(
        userId: user.id,
        productId: widget.product.id,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.product.title} added to simulated cart ${cart.id}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to add product: $error')),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: CustomText(
              text: label,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: CustomText(text: value)),
        ],
      ),
    );
  }
}
