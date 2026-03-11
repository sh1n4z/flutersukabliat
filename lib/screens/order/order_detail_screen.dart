// migrated to feature folder

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: AppColors.ebonyDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Trạng thái: ${order.status}'),
            const SizedBox(height: 8),
            Text('Tổng tiền: ${order.totalPrice.toStringAsFixed(0)}đ'),
            const SizedBox(height: 16),
            const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((i) => Text('- ${i.title} x${i.qty}')),
          ],
        ),
      ),
    );
  }
}
