import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedTab = 'all';

  final List<Map<String, String>> _tabs = [
    {'id': 'all', 'label': 'Tất cả'},
    {'id': 'processing', 'label': 'Đang xử lý'},
    {'id': 'shipping', 'label': 'Đang giao'},
    {'id': 'delivered', 'label': 'Đã giao'},
    {'id': 'cancelled', 'label': 'Đã hủy'},
  ];

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return {'label': 'Đã giao', 'color': Colors.green.shade700, 'bg': Colors.green.shade50, 'icon': Icons.check_circle};
      case 'shipping':
        return {'label': 'Đang giao', 'color': Colors.blue.shade700, 'bg': Colors.blue.shade50, 'icon': Icons.local_shipping};
      case 'processing':
        return {'label': 'Đang xử lý', 'color': Colors.orange.shade700, 'bg': Colors.orange.shade50, 'icon': Icons.schedule};
      case 'cancelled':
        return {'label': 'Đã hủy', 'color': Colors.red.shade700, 'bg': Colors.red.shade50, 'icon': Icons.cancel};
      default:
        return {'label': status, 'color': Colors.grey.shade700, 'bg': Colors.grey.shade50, 'icon': Icons.info};
    }
  }

  void _showReviewModal(BuildContext context, Map<String, dynamic> item) {
    int selectedRating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ĐÁNH GIÁ SẢN PHẨM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ebonyDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            (item['imageUrl'] is List && (item['imageUrl'] as List).isNotEmpty)
                                ? item['imageUrl'][0]
                                : (item['imageUrl'] is String ? item['imageUrl'] : ''),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['title'] ?? 'Sản phẩm',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.ebonyDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Chất lượng sản phẩm',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ebonyDark),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setModalState(() => selectedRating = index + 1),
                          icon: Icon(
                            index < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.woodAccent,
                            size: 40,
                          ),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ cảm nhận của bạn...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        fillColor: AppColors.background,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (isSubmitting || selectedRating == 0)
                            ? null
                            : () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;
                                setModalState(() => isSubmitting = true);
                                try {
                                  final payload = {
                                    'productId': item['productId'] ?? item['id'],
                                    'userId': user.uid,
                                    'userName': user.displayName ?? 'Khách hàng',
                                    'rating': selectedRating,
                                    'comment': commentController.text.trim(),
                                    'createdAt': FieldValue.serverTimestamp(),
                                  };
                                  await FirebaseFirestore.instance.collection('reviews').add(payload);
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cảm ơn bạn đã đánh giá!'),
                                        backgroundColor: AppColors.ebonyDark,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ebonyDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('GỬI ĐÁNH GIÁ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('LỊCH SỬ ĐƠN HÀNG')),
        body: const Center(child: Text('Vui lòng đăng nhập để xem đơn hàng.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử đơn hàng',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // TABS SECTION
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab['id']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.ebonyDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.ebonyDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // ORDER LIST SECTION
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.woodAccent));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Filter theo tab
                final filteredDocs = _selectedTab == 'all' 
                    ? docs 
                    : docs.where((doc) {
                        final status = (doc.data() as Map<String, dynamic>)['status']?.toString().toLowerCase() ?? '';
                        return status == _selectedTab;
                      }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.ebonyDark.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        const Text("Không tìm thấy đơn hàng nào", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTab == 'all' ? 'Hãy bắt đầu mua sắm ngay!' : 'Bạn chưa có đơn hàng ${_tabs.firstWhere((t) => t['id'] == _selectedTab)['label']?.toLowerCase()}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final orderId = filteredDocs[index].id;
                    final displayId = '#${orderId.substring(0, 8).toUpperCase()}';
                    
                    final status = data['status']?.toString() ?? 'Processing';
                    final statusConfig = _getStatusConfig(status);
                    
                    final orderDate = data['orderDate'] as Timestamp?;
                    final dateStr = orderDate != null 
                        ? DateFormat('dd MMM, yyyy').format(orderDate.toDate()) 
                        : 'N/A';
                    
                    final totalPrice = data['totalPrice'] ?? 0;
                    final items = (data['items'] as List<dynamic>?) ?? [];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(displayId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusConfig['bg'],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(statusConfig['icon'], size: 14, color: statusConfig['color']),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusConfig['label'],
                                        style: TextStyle(color: statusConfig['color'], fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Items List
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: items.map<Widget>((item) {
                                final imageUrl = (item['imageUrl'] is List && (item['imageUrl'] as List).isNotEmpty) 
                                    ? item['imageUrl'][0] 
                                    : (item['imageUrl'] is String ? item['imageUrl'] : '');

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'] ?? 'Sản phẩm',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('SL: ${item['qty']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                                Text(
                                                  currencyFormat.format(item['price'] ?? 0),
                                                  style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Footer Actions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.grey.shade100)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tổng tiền', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                    Text(
                                      currencyFormat.format(totalPrice),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.ebonyDark),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (status.toLowerCase() == 'delivered')
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if (items.isNotEmpty) {
                                              _showReviewModal(context, items[0] as Map<String, dynamic>);
                                            }
                                          },
                                          icon: const Icon(Icons.star, size: 16, color: Colors.amber),
                                          label: const Text('Đánh giá', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.ebonyDark,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng mua lại đang phát triển')));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.ebonyDark,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Mua Lại', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    if (status.toLowerCase() == 'processing' || status.toLowerCase() == 'shipping')
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng theo dõi đang phát triển')));
                                          },
                                          icon: const Icon(Icons.local_shipping_outlined, size: 16),
                                          label: const Text('Theo Dõi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade50,
                                            foregroundColor: Colors.blue.shade700,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xem chi tiết đang phát triển')));
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.ebonyDark,
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Chi Tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}