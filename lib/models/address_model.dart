class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String streetDetail;
  final bool isDefault;
  final String type; // 'Nhà Riêng' hoặc 'Văn Phòng'

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.streetDetail,
    this.isDefault = false,
    this.type = 'Nhà Riêng',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'province': province,
      'district': district,
      'ward': ward,
      'streetDetail': streetDetail,
      'isDefault': isDefault,
      'type': type,
    };
  }

  factory AddressModel.fromMap(String id, Map<String, dynamic> map) {
    return AddressModel(
      id: id,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      province: map['province']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      ward: map['ward']?.toString() ?? '',
      streetDetail: map['streetDetail']?.toString() ?? '',
      isDefault: map['isDefault'] ?? false,
      type: map['type']?.toString() ?? 'Nhà Riêng',
    );
  }

  String get fullAddress => "$streetDetail, $ward, $district, $province";
}
