import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../services/auth_service.dart';
import 'order_history_screen.dart';
import 'account_info_screen.dart' hide AppColors;
import 'address_list_screen.dart';
import 'favorite_screen.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        Map<String, dynamic> userData = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          userData = snapshot.data!.data() as Map<String, dynamic>;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. PHẦN TOP: GOM HEADER VÀ STATS VÀO STACK ĐỂ NỔI KHỐI
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none, // Quan trọng để stats card có thể lòi ra ngoài
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Header màu Ebony
                    _buildHeader(userData, user?.email ?? 'N/A'),
                    // Stats Card nổi
                    Positioned(
                      bottom: -40, // Đẩy xuống một nửa để đè lên ranh giới
                      left: 24,
                      right: 24,
                      child: _buildStats(context),
                    ),
                  ],
                ),
              ),
              
              // 2. KHOẢNG CÁCH SAU STATS CARD
              const SliverToBoxAdapter(child: SizedBox(height: 60)),

              // 3. DANH SÁCH MENU QUẢN LÝ
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("TÀI KHOẢN CỦA TÔI"),
                      const SizedBox(height: 12),
                      _buildMenuCard([
                        _buildMenuItem(
                          context,
                          Icons.person_outline_rounded,
                          'Thông tin cá nhân',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountInfoScreen(initialData: userData))),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.location_on_outlined,
                          'Địa chỉ giao hàng',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.history_outlined,
                          'Đơn hàng đã mua',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
                        ),
                      ]),
                      
                      const SizedBox(height: 32),
                      _sectionTitle("CÀI ĐẶT & HỖ TRỢ"),
                      const SizedBox(height: 12),
                      _buildMenuCard([
                        _buildMenuItem(context, Icons.notifications_none_rounded, 'Thông báo ứng dụng', isSwitch: true),
                        _buildDivider(),
                        _buildMenuItem(context, Icons.headset_mic_outlined, 'Tổng đài chăm sóc'),
                        _buildDivider(),
                        _buildMenuItem(context, Icons.info_outline_rounded, 'Về Ebony Furniture'),
                      ]),
                      
                      const SizedBox(height: 48),
                      _buildLogoutButton(context, auth),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(Map<String, dynamic> data, String email) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.ebonyDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.woodAccent.withOpacity(0.4), width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.ebonyMedium,
              child: Icon(Icons.person_rounded, size: 45, color: AppColors.woodAccent),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['name'] ?? '23').toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.woodAccent.withOpacity(0.2)),
                  ),
                  child: const Text(
                    "PREMIUM MEMBER",
                    style: TextStyle(color: AppColors.woodAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final auth = AuthService();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.ebonyDark.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildClickableStat(
            context,
            child: _buildStatItemStream(auth, 'Đơn hàng'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
          ),
          _buildStatDivider(),
          _buildClickableStat(
            context,
            child: _buildStatItem(favoriteProvider.items.length.toString(), 'Yêu thích'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen())),
          ),
          _buildStatDivider(),
          _buildClickableStat(
            context,
            child: _buildStatItem(cartProvider.totalItems.toString(), 'Giỏ hàng'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableStat(BuildContext context, {required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildStatItemStream(AuthService auth, String label) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildStatItem(count.toString(), label);
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.ebonyDark),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 35, color: Colors.grey.withOpacity(0.12));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 2),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isSwitch = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      leading: Icon(icon, color: AppColors.ebonyDark.withOpacity(0.8), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ebonyDark)),
      trailing: isSwitch
          ? Switch(value: true, onChanged: (v) {}, activeColor: AppColors.woodAccent)
          : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 24, endIndent: 24, color: AppColors.background);
  }

  Widget _buildLogoutButton(BuildContext context, AuthService auth) {
    return Center(
      child: InkWell(
        onTap: () async {
          await auth.signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'ĐĂNG XUẤT TÀI KHOẢN',
            style: TextStyle(color: Colors.red.shade400, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}
