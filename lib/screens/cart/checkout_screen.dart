import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../models/address_model.dart';
import '../address/edit_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Set<String> selectedItemIds;

  const CheckoutScreen({
    super.key,
    required this.selectedItemIds,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;
  String _paymentMethod = 'COD';
  bool _isLoading = false;
  final double _shippingFee = 30000;
  final TextEditingController _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }
  
  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses').where('isDefault', isEqualTo: true).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() => _selectedAddress = AddressModel.fromMap(snapshot.docs.first.id, snapshot.docs.first.data()));
      }
    } catch (e) {
      // Silent error
    }
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("CHỌN ĐỊA CHỈ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 2)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx); // Đóng BottomSheet hiện tại
                        // Chuyển sang form tạo địa chỉ mới (truyền address = null)
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditAddressScreen()));
                      },
                      icon: const Icon(Icons.add, size: 16, color: AppColors.ebonyDark),
                      label: const Text("Thêm mới", style: TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (docs.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("Bạn chưa có địa chỉ nào. Hãy thêm mới nhé!", style: TextStyle(color: Colors.grey))),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                              onPressed: () {
                                Navigator.pop(ctx);
                                // Chuyển sang form sửa địa chỉ (truyền object addr vào)
                                Navigator.push(context, MaterialPageRoute(builder: (_) => EditAddressScreen(address: addr)));
                              },
                            ),
                            if (_selectedAddress?.id == addr.id) 
                              const Icon(Icons.check_circle, color: AppColors.woodAccent),
                          ],
                        ),
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

  Future<void> _placeOrder(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showErrorSnackBar('Vui lòng đăng nhập để đặt hàng.');
      return;
    }

    if (_selectedAddress == null) {
      _showErrorSnackBar('Vui lòng chọn địa chỉ giao hàng.');
      return;
    }

    // Lọc sản phẩm từ CartProvider dựa trên selectedItemIds
    final selectedCartItems = cart.items.values
        .where((item) => widget.selectedItemIds.contains(item.cartItemId))
        .toList();

    if (selectedCartItems.isEmpty) {
      _showErrorSnackBar('Danh sách sản phẩm lỗi. Vui lòng thử lại.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      double subtotal = 0.0;
      for (var item in selectedCartItems) {
        subtotal += item.qty * item.product.price;
      }
      final totalAmount = subtotal + _shippingFee;

      final orderData = {
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'status': 'Processing',
        'orderDate': FieldValue.serverTimestamp(),
        'paymentMethod': _paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng (COD)' : _paymentMethod,
        'totalPrice': totalAmount,
        'paymentDetail': {
          'subtotal': subtotal,
          'shippingFee': _shippingFee,
          'discount': 0,
          'totalAmount': totalAmount,
        },
        'shippingAddress': _selectedAddress!.toMap(),
        'items': selectedCartItems.map((item) => {
          'id': item.product.id,
          'productId': item.product.id,
          'title': item.product.title,
          'quantity': item.qty,
          'qty': item.qty,
          'price': item.product.price,
          'imageUrl': item.product.imageUrl,
          'selectedColor': item.selectedColor,
          'selectedSize': item.selectedSize,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Xóa các món đã mua khỏi giỏ hàng
      for (var item in selectedCartItems) {
        await cart.remove(item.cartItemId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Đặt hàng thành công!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi đặt hàng: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Lọc items để hiển thị
    final selectedItems = cart.items.values
        .where((item) => widget.selectedItemIds.contains(item.cartItemId))
        .toList();

    // Tính toán
    double subtotal = 0.0;
    for (var item in selectedItems) {
      subtotal += item.qty * item.product.price;
    }
    final total = subtotal + _shippingFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        title: const Text(
          'XÁC NHẬN ĐƠN HÀNG',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KHỐI 1: ĐỊA CHỈ
                  _buildSectionTitle('ĐỊA CHỈ GIAO HÀNG'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _showAddressPicker,
                    child: _buildSection(
                      title: "ĐỊA CHỈ NHẬN HÀNG",
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
                  const SizedBox(height: 24),

                  // KHỐI 2: DANH SÁCH SẢN PHẨM (TÓM TẮT)
                  _buildSectionTitle('SẢN PHẨM (${selectedItems.length})'),
                  const SizedBox(height: 12),
                  ...selectedItems.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("${item.selectedColor} | ${item.selectedSize}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(currencyFormat.format(item.product.price), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text("x${item.qty}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // KHỐI 3: PHƯƠNG THỨC THANH TOÁN
                  _buildSectionTitle('THANH TOÁN'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'COD',
                          groupValue: _paymentMethod,
                          activeColor: AppColors.woodAccent,
                          title: const Text('Thanh toán khi nhận hàng (COD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          onChanged: (val) => setState(() => _paymentMethod = val!),
                        ),
                        RadioListTile<String>(
                          value: 'Banking',
                          groupValue: _paymentMethod,
                          activeColor: AppColors.woodAccent,
                          title: const Text('Chuyển khoản ngân hàng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          onChanged: (val) => setState(() => _paymentMethod = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Voucher Input (Optional)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: _voucherController,
                      decoration: InputDecoration(
                        hintText: 'Nhập mã giảm giá (nếu có)',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        border: InputBorder.none,
                        suffixIcon: TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển'))),
                          child: const Text('ÁP DỤNG', style: TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // BOTTOM BAR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tạm tính:', style: TextStyle(color: Colors.grey)), Text(currencyFormat.format(subtotal), style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Phí vận chuyển:', style: TextStyle(color: Colors.grey)), Text(currencyFormat.format(_shippingFee), style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(currencyFormat.format(total), style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.w900, fontSize: 20))]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _placeOrder(cart),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.ebonyDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ĐẶT HÀNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.woodAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: AppColors.woodAccent, size: 16), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 1.5))]),
        const SizedBox(height: 20), child
      ]),
    );
  }
}
