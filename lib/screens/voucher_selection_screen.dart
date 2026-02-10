import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/voucher_provider.dart';
import '../models/voucher_model.dart';

class VoucherSelectionScreen extends StatelessWidget {
  final double currentSubtotal;
  const VoucherSelectionScreen({super.key, required this.currentSubtotal});

  @override
  Widget build(BuildContext context) {
    final voucherProvider = Provider.of<VoucherProvider>(context);
    final vouchers = voucherProvider.vouchers;

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
        title: const Text(
          'CHỌN MÃ GIẢM GIÁ',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: vouchers.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: vouchers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final bool isEligible = currentSubtotal >= voucher.minOrderAmount;
                
                return _buildVoucherItem(context, voucher, isEligible, voucherProvider);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Không có mã giảm giá nào khả dụng"));
  }

  Widget _buildVoucherItem(BuildContext context, VoucherModel voucher, bool isEligible, VoucherProvider provider) {
    final bool isSelected = provider.selectedVoucher?.id == voucher.id;

    return Opacity(
      opacity: isEligible ? 1.0 : 0.5,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.woodAccent, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: InkWell(
          onTap: isEligible ? () {
            provider.selectVoucher(voucher);
            Navigator.pop(context);
          } : null,
          child: Row(
            children: [
              Container(
                width: 80,
                decoration: const BoxDecoration(
                  color: AppColors.ebonyDark,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    voucher.isPercentage ? "${voucher.discountAmount.toInt()}%" : "\$${voucher.discountAmount.toInt()}",
                    style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(voucher.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Đơn tối thiểu \$${voucher.minOrderAmount.toInt()}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("HSD: ${DateFormat('dd/MM/yyyy').format(voucher.expiryDate)}", style: const TextStyle(fontSize: 10, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.check_circle, color: AppColors.woodAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
