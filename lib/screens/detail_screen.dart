import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _quantity = 1;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 1;
  late TabController _tabController;
  final _rtdb = FirebaseDatabase.instance.ref();

  final List<Map<String, dynamic>> _productColors = [
    {'name': 'Natural Oak', 'color': const Color(0xFFD4A574), 'available': true},
    {'name': 'Dark Walnut', 'color': const Color(0xFF5D4037), 'available': true},
    {'name': 'White Ash', 'color': const Color(0xFFF5F5F5), 'available': true},
  ];

  final List<Map<String, dynamic>> _productSizes = [
    {'name': 'Small', 'dimensions': '80×60cm', 'available': true},
    {'name': 'Medium', 'dimensions': '100×80cm', 'available': true},
    {'name': 'Large', 'dimensions': '120×100cm', 'available': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    // Giảm số người xem khi thoát
    _updateViewCount(-1);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ebonyDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.ebonyDark), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border, color: AppColors.ebonyDark), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gallery
                Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: product.images.length,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (ctx, i) => Image.network(product.images[i], fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(product.images.length, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentImageIndex == index ? 20 : 6,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index ? AppColors.woodAccent : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),

                // 2. Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.category.toUpperCase(), style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                          
                          // HIỂN THỊ SỐ NGƯỜI XEM TỪ REALTIME DATABASE
                          StreamBuilder(
                            stream: _rtdb.child('live_views/${product.id}').onValue,
                            builder: (context, snapshot) {
                              int views = 0;
                              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                                views = snapshot.data!.snapshot.value as int;
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.remove_red_eye, size: 12, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text("$views đang xem", style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(product.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.woodAccent, size: 18),
                          const SizedBox(width: 4),
                          const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Text("(124 đánh giá)", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          const Spacer(),
                          const Text("Còn hàng", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("\$${product.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ebonyDark)),
                    ],
                  ),
                ),

                const Divider(indent: 20, endIndent: 20),

                // 3. Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOptionHeader("MÀU SẮC", _productColors[_selectedColorIndex]['name']),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_productColors.length, (index) {
                          final colorData = _productColors[index];
                          final bool isSelected = _selectedColorIndex == index;
                          return GestureDetector(
                            onTap: colorData['available'] ? () => setState(() => _selectedColorIndex = index) : null,
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppColors.woodAccent : Colors.transparent, width: 2),
                              ),
                              child: CircleAvatar(radius: 16, backgroundColor: (colorData['color'] as Color).withOpacity(colorData['available'] ? 1.0 : 0.3)),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      _buildOptionHeader("KÍCH THƯỚC", _productSizes[_selectedSizeIndex]['dimensions']),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_productSizes.length, (index) {
                          final sizeData = _productSizes[index];
                          final bool isSelected = _selectedSizeIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: sizeData['available'] ? () => setState(() => _selectedSizeIndex = index) : null,
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.ebonyDark : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? AppColors.ebonyDark : Colors.grey.shade200),
                                ),
                                child: Text(sizeData['name'], textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : AppColors.ebonyDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // 4. Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.ebonyDark,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.woodAccent,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  tabs: const [Tab(text: "MÔ TẢ"), Tab(text: "CHI TIẾT")],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(padding: const EdgeInsets.all(20), child: Text(product.description, style: const TextStyle(color: AppColors.woodAccent, height: 1.6))),
                      Padding(padding: const EdgeInsets.all(20), child: Column(children: [_buildSpecRow("Chất liệu", "Gỗ Sồi nguyên khối"), _buildSpecRow("Hoàn thiện", "Dầu tự nhiên"), _buildSpecRow("Xuất xứ", "Ebony VN")])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. NÚT ADD TO CART
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
                        Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() => _quantity++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        cart.add(
                          product, 
                          quantity: _quantity, 
                          color: _productColors[_selectedColorIndex]['name'], 
                          size: _productSizes[_selectedSizeIndex]['name']
                        );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm $_quantity ${product.title} vào giỏ!")));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.ebonyDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("THÊM VÀO GIỎ HÀNG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionHeader(String title, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ebonyDark))]);
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }
}
