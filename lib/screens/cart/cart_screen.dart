import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // 1. State theo dõi các món được chọn (Checkbox)
  final Set<String> _selectedItems = {};

  // Hàm tính tổng tiền dựa trên các món được chọn
  double _calculateSelectedSubtotal(CartProvider cart) {
    double total = 0.0;
    for (var item in cart.items.values) {
      if (_selectedItems.contains(item.cartItemId)) {
        total += item.qty * item.product.price;
      }
    }
    return total;
  }

  void _goToCheckout() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm để thanh toán'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(selectedItemIds: _selectedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        elevation: 0,
        title: const Text(
          'GIỎ HÀNG & THANH TOÁN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        // Đã sửa lại phần leading để chặn lỗi màn đen
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null, // Trả về null thì Flutter tự động ẩn nút Back đi nếu không có trang để lùi
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KHỐI 1: DANH SÁCH SẢN PHẨM
                        _buildSectionTitle('SẢN PHẨM (${cart.totalItems})'),
                        const SizedBox(height: 12),
                        ...cart.items.values.map((item) => _buildCartItem(item, cart, currencyFormat)),
                        
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
                // BƯỚC 2: STICKY BOTTOM NAVIGATION
                _buildBottomBar(cart, currencyFormat),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.ebonyDark.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'GIỎ HÀNG TRỐNG',
            style: TextStyle(
              color: AppColors.ebonyDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'TIẾP TỤC MUA SẮM',
              style: TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.woodAccent,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart, NumberFormat format) {
    return Dismissible(
      key: ValueKey(item.cartItemId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => cart.remove(item.cartItemId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // 1. Checkbox chọn sản phẩm
            Checkbox(
              value: _selectedItems.contains(item.cartItemId),
              activeColor: AppColors.woodAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedItems.add(item.cartItemId);
                  } else {
                    _selectedItems.remove(item.cartItemId);
                  }
                });
              },
            ),
            
            // Card sản phẩm
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Ảnh sản phẩm
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.ebonyDark,
                                  ),
                                ),
                              ),
                              // 2. Nút Xóa (Delete Button)
                              InkWell(
                                onTap: () => cart.remove(item.cartItemId),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            format.format(item.product.price),
                            style: const TextStyle(
                              color: AppColors.woodAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tăng giảm số lượng
                          Row(
                            children: [
                              _buildQtyBtn(Icons.remove, () => cart.changeQty(item.cartItemId, item.qty - 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '${item.qty}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              _buildQtyBtn(Icons.add, () => cart.changeQty(item.cartItemId, item.qty + 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.ebonyDark),
      ),
    );
  }

  Widget _buildBottomBar(CartProvider cart, NumberFormat format) {
    // Tính tổng tiền dựa trên các món được chọn
    final subtotal = _calculateSelectedSubtotal(cart);
    // Ở màn hình Cart chỉ hiện tạm tính, chưa cộng ship
    final isButtonEnabled = _selectedItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tạm tính:', style: TextStyle(color: Colors.grey)),
                Text(format.format(subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? _goToCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? AppColors.ebonyDark : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ĐI ĐẾN THANH TOÁN (${_selectedItems.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5,
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