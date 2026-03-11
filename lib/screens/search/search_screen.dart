import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;

  // 🎨 Design System Colors
  final Color _ebonyDark = const Color(0xFF1A1410);
  final Color _woodAccent = const Color(0xFFA88860);
  final Color _background = const Color(0xFFFAF8F5);

  @override
  void initState() {
    super.initState();
    // Tự động focus và tải dữ liệu nếu cần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
      _loadInitialData();
    });
  }

  // ⚙️ Logic: Gọi Firestore thông qua Provider
  Future<void> _loadInitialData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    // Chỉ tải lại nếu chưa có dữ liệu để tối ưu
    if (provider.products.isEmpty && provider.searchQuery.isEmpty) {
      setState(() => _isLoading = true);
      try {
        await provider.fetchProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi kết nối: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _ebonyDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            productProvider.clearSearch();
            Navigator.of(context).pop();
          },
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: _woodAccent,
          decoration: const InputDecoration(
            hintText: 'TÌM KIẾM SẢN PHẨM...', // Typography: IN HOA
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            productProvider.searchProducts(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: _woodAccent),
              onPressed: () {
                _searchController.clear();
                productProvider.clearSearch();
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_woodAccent),
              ),
            )
          : products.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) =>
                        _buildProductItem(products[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: _ebonyDark.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'NHẬP TÊN ĐỂ KHÁM PHÁ'
                : 'KHÔNG TÌM THẤY KẾT QUẢ',
            style: TextStyle(
              color: _ebonyDark,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Rule: Bo góc 15-30px
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Rule: Shadow cực nhẹ
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
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF5F3F0),
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title.toUpperCase(), // Rule: Tiêu đề IN HOA
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _ebonyDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _woodAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (product.rating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: _woodAccent),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(
                                color: _ebonyDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
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