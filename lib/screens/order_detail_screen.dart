import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import '../models/product.dart';
import 'detail_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _currentOrder;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  // HÀM XỬ LÝ HỦY ĐƠN HÀNG
  Future<void> _handleCancelOrder() async {
    final TextEditingController reasonController = TextEditingController();
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hủy đơn hàng", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác."),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "Nhập lý do hủy (ví dụ: Đổi ý, sai địa chỉ...)",
                hintStyle: const TextStyle(fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("KHÔNG", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("XÁC NHẬN HỦY", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isCancelling = true);
      try {
        final String reason = reasonController.text.trim().isEmpty ? "Khách hàng yêu cầu hủy" : reasonController.text.trim();

        // 1. Cập nhật trạng thái trên Firestore
        await FirebaseFirestore.instance.collection('orders').doc(_currentOrder.id).update({
          'status': 'Cancelled',
          'cancellationReason': reason,
        });

        // 2. Tạo thông báo hủy đơn cho đúng User
        await FirebaseFirestore.instance.collection('users').doc(_currentOrder.userId).collection('notifications').add({
          'title': 'Đơn hàng đã hủy',
          'body': 'Đơn hàng #${_currentOrder.id.substring(0, 8).toUpperCase()} đã được hủy thành công.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'system',
        });

        // 3. Cập nhật UI cục bộ
        setState(() {
          _currentOrder = OrderModel(
            id: _currentOrder.id,
            userId: _currentOrder.userId,
            orderDate: _currentOrder.orderDate,
            totalPrice: _currentOrder.totalPrice,
            status: 'Cancelled',
            items: _currentOrder.items,
            shippingAddress: _currentOrder.shippingAddress,
            paymentMethod: _currentOrder.paymentMethod,
            paymentDetail: _currentOrder.paymentDetail,
            cancellationReason: reason,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã hủy đơn hàng thành công")));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      } finally {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = _currentOrder.status.toLowerCase() == 'cancelled' || _currentOrder.status == 'ĐÃ HỦY';
    final bool canCancel = _currentOrder.status.toLowerCase() == 'shipping' || _currentOrder.status == 'CHỜ GIAO' || _currentOrder.status.toLowerCase() == 'processing';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "CHI TIẾT ĐƠN HÀNG #${_currentOrder.id.substring(0, 8).toUpperCase()}",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildStatusHeader(isCancelled),

            _buildSection(
              title: "ĐỊA CHỈ GIAO HÀNG",
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_currentOrder.shippingAddress.name} | ${_currentOrder.shippingAddress.phone}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
                  const SizedBox(height: 6),
                  Text(_currentOrder.shippingAddress.fullAddress, 
                    style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.6), fontSize: 13, height: 1.4)),
                ],
              ),
            ),

            _buildSection(
              title: "THÔNG TIN SẢN PHẨM",
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: _currentOrder.items.map((item) => InkWell(
                  onTap: () async {
                    final doc = await FirebaseFirestore.instance.collection('products').doc(item.productId).get();
                    if (doc.exists && context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: Product.fromMap(doc.id, doc.data()!))));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(item.imageUrl[0], width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
                              const SizedBox(height: 4),
                              Text("Màu: ${item.selectedColor} | Size: ${item.selectedSize}", 
                                style: TextStyle(fontSize: 11, color: AppColors.ebonyDark.withOpacity(0.4))),
                              const SizedBox(height: 4),
                              Text("x${item.qty}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),

            _buildSection(
              title: "CHI TIẾT THANH TOÁN",
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _infoRow("Ngày đặt hàng", DateFormat('dd/MM/yyyy HH:mm').format(_currentOrder.orderDate)),
                  if (isCancelled)
                    _infoRow("Lý do hủy", _currentOrder.cancellationReason ?? "Hệ thống hủy", isRed: true),
                  _infoRow("Phương thức", _currentOrder.paymentMethod),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  _priceRow("TỔNG THANH TOÁN", NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_currentOrder.totalPrice), isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 40),
            _buildActionButtons(canCancel),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isCancelled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: AppColors.ebonyDark,
      child: Column(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.auto_awesome_rounded, 
            color: isCancelled ? Colors.red.shade300 : AppColors.woodAccent, 
            size: 40
          ),
          const SizedBox(height: 16),
          Text(
            isCancelled ? "ĐÃ HỦY ĐƠN HÀNG" : _currentOrder.status.toUpperCase(), 
            style: TextStyle(color: isCancelled ? Colors.red.shade300 : Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)
          ),
          const SizedBox(height: 8),
          Text(
            isCancelled ? "Đơn hàng đã được hủy bỏ và tiền sẽ được hoàn lại (nếu có)." : "Cảm ơn bạn đã tin tưởng Ebony Furniture", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.ebonyDark.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.woodAccent, size: 16),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.5), fontSize: 13)),
          Text(value, style: TextStyle(color: isRed ? Colors.red.shade400 : AppColors.ebonyDark, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.w900, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.w900, fontSize: 20)),
      ],
    );
  }

  Widget _buildActionButtons(bool canCancel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (canCancel)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _isCancelling ? null : _handleCancelOrder,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isCancelling 
                  ? const CircularProgressIndicator(color: Colors.red)
                  : const Text("HỦY ĐƠN HÀNG", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ebonyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("QUAY LẠI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
