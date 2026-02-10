import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final double minOrderAmount;
  final DateTime expiryDate;
  final bool isPercentage;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.minOrderAmount,
    required this.expiryDate,
    this.isPercentage = false,
  });

  factory VoucherModel.fromMap(String id, Map<String, dynamic> map) {
    return VoucherModel(
      id: id,
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0).toDouble(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isPercentage: map['isPercentage'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discountAmount': discountAmount,
      'minOrderAmount': minOrderAmount,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isPercentage': isPercentage,
    };
  }
}
