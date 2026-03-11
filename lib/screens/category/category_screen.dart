import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../theme/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';
  final String category;
  final double? minPrice;
  final double? maxPrice;

  const CategoryScreen({
    super.key,
    required this.category,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    // 🛠️ LOGIC QUERY MỚI (Theo yêu cầu)
    // Bước 1: Khởi tạo query cơ bản vào collection products
    Query query = FirebaseFirestore.instance.collection('products');

    // Bước 2: Kiểm tra nếu không phải 'All' thì mới filter
    // Lưu ý: Giữ nguyên widget.category để so sánh chính xác với Firestore
    if (widget.category.toLowerCase() != 'all') {
      query = query.where('category', isEqualTo: widget.category);
    }

    // Bước 2: Lọc theo giá (nếu có)
    if (widget.minPrice != null && widget.maxPrice != null) {
      query = query
          .where('price', isGreaterThanOrEqualTo: widget.minPrice)
          .where('price', isLessThanOrEqualTo: widget.maxPrice);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.category.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(), // ✅ Truyền query đã xử lý vào đây
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Lỗi tải dữ liệu (Có thể cần tạo Index trên Firebase Console): ${snapshot.error}', 
                  style: const TextStyle(color: AppColors.error, fontSize: 12), textAlign: TextAlign.center),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.woodAccent),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.ebonyDark.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'KHÔNG CÓ SẢN PHẨM',
                    style: TextStyle(
                      color: AppColors.ebonyDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Danh mục: "${widget.category}"',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final product = Product.fromMap(docs[index].id, data);
              return _buildProductItem(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5F3F0),
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.ebonyDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ebonyDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(product.price),
                    style: const TextStyle(
                      color: AppColors.woodAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}