// migrated to feature folder
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../services/auth_service.dart';
import '../product/detail_screen.dart';
import '../notification/notification_screen.dart';
import '../category/category_screen.dart';
import '../../widgets/categories_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// (file body unchanged, moved from original)
// NOTE: logic preserved; only imports adjusted for new path

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'icon': Icons.grid_view_rounded, 'label': 'All'},
    {'id': 'Living Room', 'icon': Icons.chair_rounded, 'label': 'Living Room'},
    {'id': 'Bedroom', 'icon': Icons.bed_rounded, 'label': 'Bedroom'},
    {'id': 'Dining', 'icon': Icons.restaurant_rounded, 'label': 'Dining'},
    {'id': 'Office', 'icon': Icons.work_rounded, 'label': 'Office'},
    {'id': 'Decor', 'icon': Icons.lightbulb_outline, 'label': 'Decor'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroBanner(),
                  _buildCategories(),
                  _buildFeaturedProducts(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = _auth.currentUser;

    return Container(
      color: AppColors.ebonyDark,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // NÚT THÔNG BÁO (Góc trên trái)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                  // Hiển thị chấm đỏ nếu có thông báo chưa đọc
                  if (user != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(user.uid)
                          .collection('notifications')
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          return Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    'EBONY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    'FURNITURE',
                    style: TextStyle(
                      color: AppColors.woodAccent,
                      fontSize: 10,
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {
                  // Chức năng tìm kiếm
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ebonyMedium, AppColors.ebonyDark],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEW COLLECTION',
              style: TextStyle(
                color: AppColors.woodAccent,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Handcrafted Elegance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.woodAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Explore', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.ebonyDark, letterSpacing: 1),
          ),
        ),
        SizedBox(
          height: 86,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final c = _categories[index];
              return GestureDetector(
                onTap: () {
                  if (c['id'] == 'all') {
                    // Nếu là 'all' thì mở Bottom Sheet hoặc xử lý hiển thị tất cả
                    CategoriesBottomSheet.show(context);
                  } else {
                    // Truyền đúng mỗi cái 'category' thôi, bỏ cái categoryName đi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(
                          category: c['id'], 
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Icon(c['icon'], color: AppColors.ebonyDark),
                    ),
                    const SizedBox(height: 8),
                    Text(c['label'], style: const TextStyle(fontSize: 11)),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: _categories.length,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs.map((d) => Product.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: docs.map<Widget>((p) => ProductCard(
            product: p,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: p)));
            },
          )).toList(),
        );
      },
    );
  }
}
