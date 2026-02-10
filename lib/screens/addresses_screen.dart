import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ebonyDark,
        title: const Text('My Addresses', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressCard(
            'Home',
            '123 Nguyen Hue Street, District 1, Ho Chi Minh City',
            true,
          ),
          _buildAddressCard(
            'Office',
            '456 Le Duan Street, District 1, Ho Chi Minh City',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String label, String address, bool isDefault) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDefault ? Border.all(color: AppColors.woodAccent, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isDefault ? AppColors.woodAccent : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.woodAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Default', style: TextStyle(color: AppColors.woodAccent, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
        ],
      ),
    );
  }
}