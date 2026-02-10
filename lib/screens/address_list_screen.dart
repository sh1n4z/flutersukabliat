import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/address_model.dart';
import '../theme/app_colors.dart';
import 'edit_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

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
          'ĐỊA CHỈ CỦA TÔI',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              "DANH SÁCH ĐỊA CHỈ",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.woodAccent.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('addresses')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.woodAccent));
                }
                
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_rounded, size: 64, color: AppColors.ebonyDark.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        const Text("Bạn chưa lưu địa chỉ nào", style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = AddressModel.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
                    return _buildAddressCard(context, address);
                  },
                );
              },
            ),
          ),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditAddressScreen(address: address))),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ebonyDark),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 12, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(width: 12),
                        Text(
                          address.phone,
                          style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.6), fontSize: 14),
                        ),
                      ],
                    ),
                    Icon(Icons.edit_location_alt_outlined, size: 18, color: AppColors.woodAccent.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  address.streetDetail,
                  style: const TextStyle(color: AppColors.ebonyDark, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  "${address.ward}, ${address.district}, ${address.province}",
                  style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.7), fontSize: 13),
                ),
                if (address.isDefault) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.woodAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.woodAccent.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'MẶC ĐỊNH',
                      style: TextStyle(color: AppColors.woodAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditAddressScreen())),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('THÊM ĐỊA CHỈ MỚI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ebonyDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}
