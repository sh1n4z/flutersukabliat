import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/voucher_provider.dart';
import '../models/voucher_model.dart';

class VoucherWalletScreen extends StatelessWidget {
  const VoucherWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'KHO VOUCHER',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, provider, child) {
          if (provider.vouchers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.vouchers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildVoucherCard(context, provider.vouchers[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_num_outlined, size: 64, color: AppColors.ebonyDark.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("Bạn chưa có mã giảm giá nào", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, VoucherModel voucher) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: 'đ');

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Phần bên trái (Icon & Giá trị)
          Container(
            width: 100,
            decoration: const BoxDecoration(
              color: AppColors.ebonyDark,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.woodAccent, size: 32),
                const SizedBox(height: 8),
                Text(
                  voucher.isPercentage ? "${voucher.discountAmount.toInt()}%" : currencyFormat.format(voucher.discountAmount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const Text("GIẢM", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          // Phần bên phải (Nội dung)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    voucher.title.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ebonyDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.description,
                    style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.5), fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "HSD: ${DateFormat('dd/MM/yyyy').format(voucher.expiryDate)}",
                        style: TextStyle(color: Colors.red.shade300, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.woodAccent, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("DÙNG NGAY", style: TextStyle(color: AppColors.woodAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
