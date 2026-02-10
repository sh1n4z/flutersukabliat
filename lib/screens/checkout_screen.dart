import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/voucher_provider.dart';
import '../services/auth_service.dart';
import '../models/address_model.dart';
import '../models/voucher_model.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;
  String _paymentMethod = 'Thanh toán khi nhận hàng (COD)';
  bool _isProcessing = false;
  final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: 'đ');

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Thanh toán khi nhận hàng (COD)', 'icon': Icons.local_shipping_outlined, 'desc': 'Thanh toán tiền mặt khi nhận hàng'},
    {'name': 'Thẻ Tín dụng / Ghi nợ', 'icon': Icons.credit_card_outlined, 'desc': 'Visa, Mastercard, JCB'},
    {'name': 'Ví điện tử (Momo/ZaloPay)', 'icon': Icons.account_balance_wallet_outlined, 'desc': 'Xác thực nhanh qua ứng dụng ví'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses').where('isDefault', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      setState(() => _selectedAddress = AddressModel.fromMap(snapshot.docs.first.id, snapshot.docs.first.data()));
    }
  }

  // CHỌN ĐỊA CHỈ
  void _showAddressPicker() {
    final user = AuthService().currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('addresses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          final docs = snapshot.data!.docs;
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CHỌN ĐỊA CHỈ GIAO HÀNG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 2)),
                const SizedBox(height: 20),
                if (docs.isEmpty) const Text("Bạn chưa có địa chỉ nào.", style: TextStyle(color: Colors.grey)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final addr = AddressModel.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${addr.name} | ${addr.phone}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ebonyDark)),
                        subtitle: Text(addr.fullAddress, style: const TextStyle(fontSize: 12)),
                        trailing: _selectedAddress?.id == addr.id ? const Icon(Icons.check_circle, color: AppColors.woodAccent) : null,
                        onTap: () { setState(() => _selectedAddress = addr); Navigator.pop(ctx); },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // CHỌN PHƯƠNG THỨC THANH TOÁN (ĐÃ FIX LỖI MỜ CHỮ)
  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ebonyDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 2)),
            const SizedBox(height: 24),
            ..._paymentMethods.map((m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(m['icon'], color: Colors.white, size: 24),
              title: Text(m['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text(m['desc'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              trailing: _paymentMethod == m['name'] ? const Icon(Icons.check_circle, color: AppColors.woodAccent) : null,
              onTap: () { setState(() => _paymentMethod = m['name']); Navigator.pop(ctx); },
            )).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cart, VoucherProvider voucher) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng")));
      return;
    }
    setState(() => _isProcessing = true);
    final user = AuthService().currentUser;
    try {
      final double discount = voucher.calculateDiscount(cart.totalPrice);
      final double totalAmount = cart.totalPrice + 25000 - discount;
      
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user!.uid,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Processing',
        'shippingAddress': _selectedAddress!.toMap(),
        'items': cart.items.values.map((i) => {
          'productId': i.product.id, 'title': i.product.title, 'price': i.product.price,
          'qty': i.qty, 'imageUrl': i.product.images, 'selectedColor': i.selectedColor, 'selectedSize': i.selectedSize
        }).toList(),
        'paymentMethod': _paymentMethod,
        'paymentDetail': { 'subtotal': cart.totalPrice, 'shippingFee': 25000, 'discount': discount, 'totalAmount': totalAmount }
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notifications').add({
        'title': 'Đặt hàng thành công', 'body': 'Đơn hàng ${currencyFormat.format(totalAmount)} đang được xử lý.',
        'timestamp': FieldValue.serverTimestamp(), 'isRead': false, 'type': 'order'
      });

      cart.clear(); voucher.clearSelection();
      if (mounted) _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Image.asset('assets/images/logo1.png', width: 80, errorBuilder: (c,e,s) => const Icon(Icons.check_circle, size: 80, color: Colors.green)),
            const SizedBox(height: 24),
            const Text("Đặt hàng thành công!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.ebonyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("VỀ TRANG CHỦ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final voucher = Provider.of<VoucherProvider>(context);
    final double discount = voucher.calculateDiscount(cart.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('XÁC NHẬN ĐƠN HÀNG', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ĐỊA CHỈ
            InkWell(
              onTap: _showAddressPicker,
              child: _buildSection(
                title: "ĐỊA CHỈ GIAO HÀNG",
                icon: Icons.location_on_outlined,
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedAddress == null 
                        ? const Text("Nhấn để chọn địa chỉ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${_selectedAddress!.name} | ${_selectedAddress!.phone}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
                              const SizedBox(height: 4),
                              Text(_selectedAddress!.fullAddress, style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.6), fontSize: 13)),
                            ],
                          ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            // SẢN PHẨM
            _buildSection(
              title: "SẢN PHẨM (${cart.totalItems})",
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: cart.items.values.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.product.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.title, maxLines: 1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
                            Text("${item.selectedColor} | ${item.selectedSize}", style: TextStyle(fontSize: 11, color: AppColors.ebonyDark.withOpacity(0.4))),
                          ],
                        ),
                      ),
                      Text(currencyFormat.format(item.product.price * item.qty), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ebonyDark)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // PHƯƠNG THỨC THANH TOÁN
            InkWell(
              onTap: _showPaymentPicker,
              child: _buildSection(
                title: "PHƯƠNG THỨC THANH TOÁN",
                icon: Icons.payment_outlined,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ebonyDark))),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // THANH TOÁN TIỀN
            _buildSection(
              title: "CHI TIẾT THANH TOÁN",
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _priceRow("Tổng tiền hàng", currencyFormat.format(cart.totalPrice)),
                  _priceRow("Phí vận chuyển", currencyFormat.format(25000)),
                  if (discount > 0) _priceRow("Giảm giá", "-${currencyFormat.format(discount)}", isDiscount: true),
                  const Divider(),
                  _priceRow("TỔNG CỘNG", currencyFormat.format(cart.totalPrice + 25000 - discount), isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _placeOrder(cart, voucher),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.ebonyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("XÁC NHẬN ĐẶT HÀNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity, margin: const EdgeInsets.fromLTRB(16, 16, 16, 0), padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: AppColors.woodAccent, size: 16), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 1.5))]),
        const SizedBox(height: 20), child
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? AppColors.ebonyDark : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: isDiscount ? Colors.red : (isTotal ? AppColors.woodAccent : AppColors.ebonyDark), fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold, fontSize: isTotal ? 20 : 14)),
        ],
      ),
    );
  }
}
