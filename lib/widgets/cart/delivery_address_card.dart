import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/address_model.dart';
import '../../screens/address/address_list_screen.dart';

class DeliveryAddressCard extends StatelessWidget {
  const DeliveryAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        AddressModel? defaultAddress;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          defaultAddress = AddressModel.fromMap(
            snapshot.data!.docs.first.id,
            snapshot.data!.docs.first.data() as Map<String, dynamic>
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ĐỊA CHỈ GIAO HÀNG", 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 1.5)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())),
                    child: const Text("THAY ĐỔI", style: TextStyle(color: AppColors.ebonyDark, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (defaultAddress != null) ...[
                Text("${defaultAddress.name} | ${defaultAddress.phone}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ebonyDark)),
                const SizedBox(height: 4),
                Text(defaultAddress.fullAddress, 
                  style: TextStyle(color: AppColors.ebonyDark.withOpacity(0.6), fontSize: 13, height: 1.4)),
              ] else
                const Text("Vui lòng thiết lập địa chỉ giao hàng mặc định", 
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}
