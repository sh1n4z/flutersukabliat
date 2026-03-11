// migrated to feature folder
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutersukabliat/models/product.dart';
import 'package:flutersukabliat/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import 'package:flutersukabliat/screens/product/product_form_screen.dart' as pf; // alias to avoid analyzer resolution issues

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppColors.ebonyDark,
                title: const Text(
                  'QUẢN LÝ CỬA HÀNG',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                centerTitle: true,
                pinned: true,
                floating: true,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.woodAccent,
                  labelColor: AppColors.woodAccent,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(icon: Icon(Icons.dashboard), text: 'Tổng quan'),
                    Tab(icon: Icon(Icons.shopping_bag), text: 'Sản phẩm'),
                    Tab(icon: Icon(Icons.receipt), text: 'Đơn hàng'),
                    Tab(icon: Icon(Icons.people), text: 'Khách hàng'),
                    Tab(icon: Icon(Icons.message), text: 'Tin nhắn'),
                    Tab(icon: Icon(Icons.settings), text: 'Cài đặt'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              _buildDashboard(context),
              _buildProductsList(),
              const Center(child: Text('Orders')),
              const Center(child: Text('Customers')),
              const Center(child: Text('Messages')),
              const Center(child: Text('Settings')),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return Visibility(
              visible: tabController?.index == 1,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => pf.ProductFormScreen()),
                  ).then((_) {
                    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
                  });
                },
                backgroundColor: AppColors.ebonyDark,
                child: const Icon(Icons.add, color: AppColors.woodAccent, size: 28),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Tổng sản phẩm', '120', Icons.shopping_bag, Colors.blue, context),
              _buildStatCard('Đơn hàng', '156', Icons.receipt, Colors.green, context),
              _buildStatCard('Khách hàng', '89', Icons.people, Colors.purple, context),
              _buildStatCard('Tin nhắn', '12', Icons.message, Colors.orange, context),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Thao tác nhanh',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickActionCard('Thêm sản phẩm', Icons.add, () {}, context),
              _buildQuickActionCard('Xem đơn hàng', Icons.receipt, () {}, context),
              _buildQuickActionCard('Tin nhắn', Icons.message, () {}, context),
              _buildQuickActionCard('Khách hàng', Icons.people, () {}, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (query) => productProvider.searchProducts(query),
                decoration: InputDecoration(
                  hintText: 'Tìm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.woodAccent),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.woodAccent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),

            Expanded(
              child: productProvider.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            productProvider.searchQuery.isEmpty
                                ? 'Chưa có sản phẩm nào'
                                : 'Không tìm thấy sản phẩm',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) {
                        final p = productProvider.products[index];
                        return ListTile(
                          leading: Image.network(p.images.first, width: 56, height: 56, fit: BoxFit.cover),
                          title: Text(p.title),
                          subtitle: Text(p.category),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap, BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.woodAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
