import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'address_list_screen.dart';

class AccountInfoScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const AccountInfoScreen({super.key, required this.initialData});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _auth = AuthService();
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = Map.from(widget.initialData);
  }

  void _showEditDialog(String field, String label, {bool isLongText = false}) {
    final controller = TextEditingController(text: _userData[field]?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Chỉnh sửa $label", style: const TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: isLongText ? 3 : 1,
          style: const TextStyle(color: AppColors.ebonyDark),
          decoration: InputDecoration(
            hintText: "Nhập $label mới",
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                final user = _auth.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({field: newValue}, SetOptions(merge: true));
                  setState(() => _userData[field] = newValue);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text("LƯU THAY ĐỔI", style: TextStyle(color: AppColors.woodAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

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
          'THÔNG TIN TÀI KHOẢN',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            _userData = snapshot.data!.data() as Map<String, dynamic>;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // PHẦN AVATAR CAO CẤP
                Container(
                  width: double.infinity,
                  color: AppColors.ebonyDark,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.woodAccent.withOpacity(0.5), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.ebonyMedium,
                          child: Icon(Icons.person, size: 50, color: AppColors.woodAccent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'HÌNH ĐẠI DIỆN',
                        style: TextStyle(color: AppColors.woodAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                _buildSectionLabel("THÔNG TIN CƠ BẢN"),
                _buildInfoCard([
                  _buildInfoRow('Họ và tên', _userData['name'] ?? 'Chưa thiết lập', onTap: () => _showEditDialog('name', 'Họ tên')),
                  _buildDivider(),
                  _buildInfoRow('Tiểu sử', _userData['bio'] ?? 'Thiết lập ngay', isHint: _userData['bio'] == null, onTap: () => _showEditDialog('bio', 'Tiểu sử', isLongText: true)),
                ]),

                const SizedBox(height: 24),
                _buildSectionLabel("CHI TIẾT CÁ NHÂN"),
                _buildInfoCard([
                  _buildInfoRow('Giới tính', _userData['gender'] ?? 'Thiết lập ngay', isHint: _userData['gender'] == null, onTap: () => _showEditDialog('gender', 'Giới tính')),
                  _buildDivider(),
                  _buildInfoRow('Ngày sinh', _userData['birthday'] ?? 'Chưa thiết lập', isHint: _userData['birthday'] == null, onTap: () => _showEditDialog('birthday', 'Ngày sinh')),
                ]),

                const SizedBox(height: 24),
                _buildSectionLabel("LIÊN HỆ & ĐỊA CHỈ"),
                _buildInfoCard([
                  _buildInfoRow('Số điện thoại', _maskPhone(_userData['phone'] ?? ''), onTap: () => _showEditDialog('phone', 'Số điện thoại')),
                  _buildDivider(),
                  _buildInfoRow('Địa chỉ', 'Quản lý danh sách địa chỉ', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()))),
                  _buildDivider(),
                  _buildInfoRow('Email', _maskEmail(user?.email ?? ''), isReadOnly: true),
                ]),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.woodAccent, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHint = false, VoidCallback? onTap, bool isReadOnly = false}) {
    return InkWell(
      onTap: isReadOnly ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15, color: AppColors.ebonyDark, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value.isEmpty ? 'Thiết lập ngay' : value,
              style: TextStyle(fontSize: 14, color: (isHint || value.isEmpty) ? Colors.grey.shade400 : AppColors.ebonyDark.withOpacity(0.7)),
            ),
            if (!isReadOnly) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.withOpacity(0.5)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: AppColors.background);
  }

  String _maskPhone(String phone) {
    if (phone.isEmpty) return 'Thiết lập ngay';
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)}********${phone.substring(phone.length - 2)}';
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    if (!email.contains('@')) return email;
    var parts = email.split('@');
    var name = parts[0];
    if (name.length < 2) return email;
    return '${name[0]}********${name[name.length - 1]}@${parts[1]}';
  }
}
