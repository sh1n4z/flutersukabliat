import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/auth_service.dart';
import 'detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view_rounded, 'label': 'All'},
    {'icon': Icons.chair_rounded, 'label': 'Living Room'},
    {'icon': Icons.bed_rounded, 'label': 'Bedroom'},
    {'icon': Icons.restaurant_rounded, 'label': 'Dining'},
    {'icon': Icons.work_rounded, 'label': 'Office'},
    {'icon': Icons.lightbulb_outline, 'label': 'Decor'},

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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ebonyDark),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['label'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['label'];
                  });
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.woodAccent : AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? AppColors.woodAccent.withOpacity(0.3) 
                                : Colors.black.withOpacity(0.05), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4)
                          ),
                        ],
                      ),
                      child: Icon(
                        category['icon'] as IconData, 
                        color: isSelected ? Colors.white : AppColors.ebonyMedium
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        fontSize: 12, 
                        color: isSelected ? AppColors.woodAccent : AppColors.textPrimary, 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    Query query = _firestore.collection('products');
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory == 'All' ? 'Featured' : _selectedCategory,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ebonyDark),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All →', style: TextStyle(color: AppColors.woodAccent)),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.woodAccent),
              ));
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No products found', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final product = Product.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: product)));
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
