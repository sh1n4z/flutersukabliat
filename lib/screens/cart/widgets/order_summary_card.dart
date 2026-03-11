import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../checkout_screen.dart';

class OrderSummaryCard extends StatelessWidget {
  final Set<String> selectedItemIds; // Thêm biến hứng data
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final double freeShippingThreshold;

  const OrderSummaryCard({
    super.key,
    required this.selectedItemIds, // Bắt buộc truyền vào
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    this.freeShippingThreshold = 500000,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: 'đ');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ebonyDark.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          _buildRow("Tạm tính", currencyFormat.format(subtotal)),
          if (discount > 0) 
            _buildRow("Khuyến mãi", "-${currencyFormat.format(discount)}", isDiscount: true),
          _buildRow("Phí vận chuyển", shipping == 0 ? "Miễn phí" : currencyFormat.format(shipping)),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 0.5),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TỔNG CỘNG", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.ebonyDark, letterSpacing: 1.5)),
              Text(currencyFormat.format(total), 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.woodAccent)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Chặn lại nếu chưa chọn món nào
                if (selectedItemIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn ít nhất một sản phẩm để thanh toán'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                
                // Truyền data sang CheckoutScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutScreen(selectedItemIds: selectedItemIds)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ebonyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text("TIẾN HÀNH ĐẶT HÀNG", 
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(
            color: isDiscount ? Colors.red.shade300 : AppColors.ebonyDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          )),
        ],
      ),
    );
  }
}