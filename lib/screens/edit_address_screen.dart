import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/address_model.dart';
import '../theme/app_colors.dart';

class EditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const EditAddressScreen({super.key, this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _streetController = TextEditingController();
  bool _isDefault = false;
  String _addressType = 'Nhà Riêng';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phone;
      _locationController.text = "${widget.address!.province}, ${widget.address!.district}, ${widget.address!.ward}";
      _streetController.text = widget.address!.streetDetail;
      _isDefault = widget.address!.isDefault;
      _addressType = widget.address!.type;
    }
  }

  Future<void> _saveAddress() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    
    final locationParts = _locationController.text.split(',');
    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'streetDetail': _streetController.text.trim(),
      'isDefault': _isDefault,
      'type': _addressType,
      'province': locationParts.isNotEmpty ? locationParts[0].trim() : '',
      'district': locationParts.length > 1 ? locationParts[1].trim() : '',
      'ward': locationParts.length > 2 ? locationParts[2].trim() : '',
    };

    try {
      final collection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses');
      
      if (_isDefault) {
        final query = await collection.where('isDefault', isEqualTo: true).get();
        for (var doc in query.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }

      if (widget.address == null) {
        await collection.add(data);
      } else {
        await collection.doc(widget.address!.id).update(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
        title: Text(
          widget.address == null ? 'ĐỊA CHỈ MỚI' : 'SỬA ĐỊA CHỈ',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner phong cách catalog
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: AppColors.ebonyDark,
              child: Text(
                'Vui lòng cung cấp địa chỉ chính xác để đảm bảo trải nghiệm giao hàng nội thất tốt nhất từ Ebony.',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("LIÊN HỆ QUÝ KHÁCH"),
            _buildInputCard([
              _buildInputField('Họ và tên người nhận', _nameController, Icons.person_outline_rounded),
              _buildDivider(),
              _buildInputField('Số điện thoại liên lạc', _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            ]),

            const SizedBox(height: 32),
            _buildSectionLabel("ĐỊA ĐIỂM GIAO HÀNG"),
            _buildInputCard([
              _buildInputField('Tỉnh/Thành phố, Quận, Phường', _locationController, Icons.map_outlined),
              _buildDivider(),
              _buildInputField('Tên đường, Số nhà, Tòa nhà...', _streetController, Icons.location_on_outlined, maxLines: 2),
            ]),

            const SizedBox(height: 32),
            _buildSectionLabel("THIẾT LẬP"),
            _buildInputCard([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ebonyDark)),
                    Switch(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeColor: AppColors.woodAccent,
                    ),
                  ],
                ),
              ),
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOẠI ĐỊA CHỈ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.woodAccent, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTypeBtn('Văn Phòng'),
                        const SizedBox(width: 12),
                        _buildTypeBtn('Nhà Riêng'),
                      ],
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 48),
            
            // 5. Nút Hoàn thành chuyên nghiệp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ebonyDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('LƯU ĐỊA CHỈ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.woodAccent, letterSpacing: 2)),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.ebonyDark.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.ebonyDark, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: AppColors.ebonyDark.withOpacity(0.4), size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 24, endIndent: 24, color: AppColors.background);
  }

  Widget _buildTypeBtn(String label) {
    final bool isSelected = _addressType == label;
    return InkWell(
      onTap: () => setState(() => _addressType = label),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ebonyDark : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.ebonyDark : Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.ebonyDark.withOpacity(0.5),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
