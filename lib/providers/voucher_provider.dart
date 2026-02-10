import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher_model.dart';

class VoucherProvider with ChangeNotifier {
  VoucherModel? _selectedVoucher;
  List<VoucherModel> _vouchers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VoucherModel? get selectedVoucher => _selectedVoucher;
  List<VoucherModel> get vouchers => _vouchers;

  VoucherProvider() {
    fetchVouchers();
  }

  // Tải danh sách voucher từ Firestore (Realtime)
  void fetchVouchers() {
    _firestore.collection('vouchers').orderBy('expiryDate').snapshots().listen((data) {
      _vouchers = data.docs.map((doc) => VoucherModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error fetching vouchers: $e");
    });
  }

  // HÀM TỰ ĐỘNG THÊM DỮ LIỆU (SEED DATA)
  // Fix lỗi ký tự $ bằng cách dùng \$
  Future<void> seedVouchers() async {
    final List<Map<String, dynamic>> dummyVouchers = [
      {
        'code': 'EBONYNEW',
        'title': 'Chào mừng thành viên mới',
        'description': 'Giảm trực tiếp \$50 cho đơn hàng nội thất đầu tiên từ \$500',
        'discountAmount': 50.0,
        'minOrderAmount': 500.0,
        'expiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'isPercentage': false,
      },
      {
        'code': 'LUXURY10',
        'title': 'Ưu đãi Premium',
        'description': 'Giảm 10% tổng giá trị đơn hàng cho dòng sản phẩm gỗ Mun',
        'discountAmount': 10.0,
        'minOrderAmount': 1000.0,
        'expiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'isPercentage': true,
      },
      {
        'code': 'FREESHIP',
        'title': 'Miễn phí vận chuyển',
        'description': 'Giảm \$25 phí vận chuyển cho đơn hàng trên \$300',
        'discountAmount': 25.0,
        'minOrderAmount': 300.0,
        'expiryDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 60))),
        'isPercentage': false,
      },
    ];

    try {
      final batch = _firestore.batch();
      for (var v in dummyVouchers) {
        final docRef = _firestore.collection('vouchers').doc();
        batch.set(docRef, v);
      }
      await batch.commit();
      debugPrint("Seeded vouchers successfully!");
    } catch (e) {
      debugPrint("Error seeding vouchers: $e");
    }
  }

  void selectVoucher(VoucherModel? voucher) {
    _selectedVoucher = voucher;
    notifyListeners();
  }

  double calculateDiscount(double subtotal) {
    if (_selectedVoucher == null || subtotal < _selectedVoucher!.minOrderAmount) {
      return 0.0;
    }
    if (_selectedVoucher!.isPercentage) {
      return subtotal * (_selectedVoucher!.discountAmount / 100);
    } else {
      return _selectedVoucher!.discountAmount;
    }
  }

  void clearSelection() {
    _selectedVoucher = null;
    notifyListeners();
  }
}
