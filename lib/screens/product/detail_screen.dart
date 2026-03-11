import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

class ProductColor {
  final String name;
  final String value;
  final bool available;

  ProductColor({
    required this.name,
    required this.value,
    required this.available,
  });
}

class ProductSize {
  final String name;
  final String dimensions;
  final bool available;

  ProductSize({
    required this.name,
    required this.dimensions,
    required this.available,
  });
}

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 1;
  bool _isLoadingAddCart = false;
  final _rtdb = FirebaseDatabase.instance.ref();

  late List<String> _images;
  late List<ProductColor> _productColors;
  late List<ProductSize> _productSizes;

  @override
  void initState() {
    super.initState();
    
    // Lấy images từ Firebase, fallback về imageUrl nếu không có
    _images = widget.product.images.isNotEmpty
        ? widget.product.images
        : (widget.product.imageUrl.isNotEmpty ? [widget.product.imageUrl] : []);

    // Parse colors từ Firebase hoặc để rỗng
    _productColors = _parseColors(widget.product.colors);

    // Parse sizes từ Firebase hoặc để rỗng
    _productSizes = _parseSizes(widget.product.sizes);

    // Nếu không có sizes hoặc colors, set về index 0 để tránh lỗi
    _selectedSizeIndex = _productSizes.isNotEmpty ? 0 : 0;
    _selectedColorIndex = 0;

    // Tăng số người xem trong RTDB
    _updateViewCount(1);
  }

  void _updateViewCount(int delta) {
    _rtdb.child('live_views/${widget.product.id}').runTransaction((Object? currentData) {
      if (currentData == null) return Transaction.success(delta > 0 ? delta : 0);
      return Transaction.success((currentData as int) + delta);
    });
  }

  @override
  void dispose() {
    _updateViewCount(-1);
    _pageController.dispose();
    super.dispose();
  }

  /// Parse màu sắc từ Firebase
  List<ProductColor> _parseColors(List<dynamic> colorsList) {
    if (colorsList.isEmpty) return [];
    
    return colorsList.map((c) {
      if (c is Map<String, dynamic>) {
        return ProductColor(
          name: c['name']?.toString() ?? 'Unknown',
          value: c['value']?.toString() ?? '#000000',
          available: c['available'] ?? true,
        );
      }
      return ProductColor(name: 'Unknown', value: '#000000', available: false);
    }).toList();
  }

  /// Parse kích cỡ từ Firebase
  List<ProductSize> _parseSizes(List<dynamic> sizesList) {
    if (sizesList.isEmpty) return [];
    
    return sizesList.map((s) {
      if (s is Map<String, dynamic>) {
        return ProductSize(
          name: s['name']?.toString() ?? 'Unknown',
          dimensions: s['dimensions']?.toString() ?? '',
          available: s['available'] ?? true,
        );
      }
      return ProductSize(name: 'Unknown', dimensions: '', available: false);
    }).toList();
  }

  Future<void> _handleAddToCart() async {
    if (_isLoadingAddCart) return;

    setState(() => _isLoadingAddCart = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final selectedColor = _productColors.isNotEmpty ? _productColors[_selectedColorIndex].name : 'Default';
      final selectedSize = _productSizes.isNotEmpty ? _productSizes[_selectedSizeIndex].name : 'Default';

      await cartProvider.add(
        widget.product,
        quantity: _quantity,
        color: selectedColor,
        size: selectedSize,
      );

      if (mounted) {
        showAppSnackBar(
          context,
          SnackBar(
            content: Text(
              '${_quantity}x ${widget.product.title} đã thêm vào giỏ hàng',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.ebonyDark,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddCart = false);
      }
    }
  }

  Future<void> _handleToggleFavorite() async {
    try {
      final favProvider = context.read<FavoriteProvider>();
      await favProvider.toggleFavorite(widget.product);

      if (mounted) {
        showAppSnackBar(
          context,
          SnackBar(
            content: Text(
              favProvider.isFavorite(widget.product.id)
                  ? 'Đã thêm vào yêu thích'
                  : 'Xóa khỏi yêu thích',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.ebonyDark,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          SnackBar(
            content: Text('Lỗi: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleShare() {
    showAppSnackBar(
      context,
      SnackBar(
        content: const Text(
          'Đã sao chép liên kết',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.ebonyDark,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),
                  _buildProductInfo(),
                  _productColors.isNotEmpty ? _buildColorSelection() : const SizedBox.shrink(),
                  _productSizes.isNotEmpty ? _buildSizeSelection() : const SizedBox.shrink(),
                  _buildFeatures(),
                  _buildTabsSection(),
                  _buildRelatedProducts(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSheet(),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _handleShare,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.share, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<FavoriteProvider>(
              builder: (context, favProvider, _) {
                final isFavorite = favProvider.isFavorite(widget.product.id);
                return GestureDetector(
                  onTap: _handleToggleFavorite,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Stack(
            children: [
              // Khung ảnh cho phép vuốt ngang
              SizedBox(
                width: double.infinity,
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      _images.isNotEmpty ? _images[index] : '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                      ),
                    );
                  },
                ),
              ),
              // Vùng bấm vô hình ở mép trái
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: GestureDetector(
                  onTap: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Vùng bấm vô hình ở mép phải
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 60,
                child: GestureDetector(
                  onTap: () {
                    if (_currentImageIndex < _images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Live View Badge
              Positioned(
                top: 16,
                right: 16,
                child: StreamBuilder(
                  stream: _rtdb.child('live_views/${widget.product.id}').onValue,
                  builder: (context, snapshot) {
                    int views = 0;
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      views = int.tryParse(snapshot.data!.snapshot.value.toString()) ?? 0;
                    }
                    if (views <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            "$views người đang xem",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Các chấm tròn (Indicators) bên dưới
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => GestureDetector(
                  onTap: () {
                    // Cập nhật lại logic khi bấm vào chấm tròn thì nó cũng trượt ảnh
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: index == _currentImageIndex ? 24 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex ? AppColors.woodAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final discountedPrice = (widget.product.price * 1.3).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ebonyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.woodAccent),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ebonyDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• 24 đánh giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '• Còn hàng',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.product.price.toStringAsFixed(0)} đ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ebonyDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${discountedPrice.toString()} đ',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '−30%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Màu sắc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ebonyDark,
                ),
              ),
              Text(
                _productColors[_selectedColorIndex].name,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              _productColors.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: _productColors[index].available
                      ? () => setState(() => _selectedColorIndex = index)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedColorIndex == index
                            ? AppColors.woodAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Opacity(
                      opacity: _productColors[index].available ? 1.0 : 0.4,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: _getColorFromHex(_productColors[index].value),
                          border: _productColors[index].value.toLowerCase() == '#ffffff' || _productColors[index].value.toLowerCase() == '#f5f5f5'
                              ? Border.all(color: Colors.grey.shade300)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    try {
      if (hex.startsWith('#')) {
        return Color(int.parse('0xff${hex.substring(1)}'));
      }
      return Colors.transparent;
    } catch (e) {
      return Colors.grey;
    }
  }

  Widget _buildSizeSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kích cỡ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ebonyDark,
                ),
              ),
              Text(
                _productSizes[_selectedSizeIndex].dimensions,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: List.generate(
              _productSizes.length,
              (index) => GestureDetector(
                onTap: _productSizes[index].available
                    ? () => setState(() => _selectedSizeIndex = index)
                    : null,
                child: Opacity(
                  opacity: _productSizes[index].available ? 1.0 : 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedSizeIndex == index
                            ? AppColors.woodAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: _selectedSizeIndex == index
                          ? AppColors.woodAccent.withOpacity(0.05)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        _productSizes[index].name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _selectedSizeIndex == index
                              ? AppColors.woodAccent
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem(
            icon: Icons.local_shipping_outlined,
            title: 'Miễn phí',
            subtitle: 'Vận chuyển',
            color: Colors.blue,
          ),
          _buildFeatureItem(
            icon: Icons.verified_outlined,
            title: 'Bảo hành',
            subtitle: '2 Năm',
            color: Colors.green,
          ),
          _buildFeatureItem(
            icon: Icons.refresh_outlined,
            title: 'Hoàn tiền',
            subtitle: '30 Ngày',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ebonyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description.isNotEmpty
                ? widget.product.description
                : 'Không có mô tả sản phẩm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đặc điểm & Thông số',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ebonyDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow("Chất liệu", "Gỗ Sồi/Óc Chó"),
          _buildSpecRow("Hoàn thiện", "Dầu tự nhiên"),
          _buildSpecRow("Xuất xứ", "Ebony Furniture VN"),
          _buildSpecRow("Bảo hành", "24 tháng"),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return StreamBuilder<QuerySnapshot>(
      // Query lấy sản phẩm cùng category, giới hạn 6 cái
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: widget.product.category)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); 
        }

        final similarProducts = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product.fromMap(doc.id, data);
        }).toList();

        // Lọc bỏ chính sản phẩm đang xem
        final filteredList = similarProducts.where((p) => p.id != widget.product.id).toList();

        if (filteredList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'SẢN PHẨM TƯƠNG TỰ',
                  style: TextStyle(
                    color: AppColors.ebonyDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true, // Quan trọng: Cho phép GridView nằm trong ScrollView
                physics: const NeverScrollableScrollPhysics(), // Tắt alone GridView
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cột
                  childAspectRatio: 0.75, // Tỷ lệ card
                  crossAxisSpacing: 16, // distanc ngang
                  mainAxisSpacing: 16, // ... dọc
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final similarProduct = filteredList[index];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: similarProduct),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
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
                            // Ảnh sản phẩm
                            Expanded(
                              child: Image.network(
                                similarProduct.images.isNotEmpty 
                                    ? similarProduct.images.first 
                                    : (similarProduct.imageUrl.isNotEmpty ? similarProduct.imageUrl : ''),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF5F3F0),
                                  child: Icon(Icons.image, color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            // Thông tin
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    similarProduct.title.toUpperCase(),
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
                                    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
                                        .format(similarProduct.price),
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
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet() {
    return SafeArea(
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _isLoadingAddCart ? null : _handleAddToCart,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.ebonyDark,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: _isLoadingAddCart
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Text(
                            'THÊM VÀO GIỎ HÀNG',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
