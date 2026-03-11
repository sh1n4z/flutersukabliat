import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PromoCodeSection extends StatelessWidget {
  final String? appliedCode;
  final Function(String) onApply;
  final VoidCallback onRemove;

  const PromoCodeSection({
    super.key,
    this.appliedCode,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MÃ GIẢM GIÁ", 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          appliedCode != null 
            ? _buildAppliedCode()
            : _buildInputField(controller),
        ],
      ),
    );
  }

  Widget _buildAppliedCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.woodAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.woodAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_num_outlined, color: AppColors.woodAccent, size: 20),
          const SizedBox(width: 12),
          Text(appliedCode!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
          const Spacer(),
          TextButton(onPressed: onRemove, child: const Text("GỠ BỎ", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Nhập mã khuyến mãi...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => onApply(controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ebonyDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text("ÁP DỤNG", style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
