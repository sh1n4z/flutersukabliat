import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kiểm tra user đã login
  User? get currentUser => _auth.currentUser;

  // ✅ Tạo đơn hàng với xác thực đầy đủ
  Future<String> createOrder({
    required AddressModel shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    double shippingFee = 25000,
  }) async {
    // 1️⃣ Kiểm tra User login
    final user = currentUser;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để đặt hàng');
    }

    // 2️⃣ Kiểm tra địa chỉ hợp lệ
    if (shippingAddress.id.isEmpty) {
      throw Exception('Vui lòng chọn địa chỉ giao hàng hợp lệ');
    }

    // 3️⃣ Kiểm tra sản phẩm không trống
    if (items.isEmpty) {
      throw Exception('Giỏ hàng trống. Vui lòng thêm sản phẩm');
    }

    // 4️⃣ Kiểm tra dữ liệu sản phẩm
    for (var item in items) {
      if (item['productId']?.isEmpty ?? true) {
        throw Exception('Sản phẩm không hợp lệ trong giỏ hàng');
      }
      if ((item['qty'] ?? 0) < 1) {
        throw Exception('Số lượng sản phẩm không hợp lệ');
      }
    }

    // 5️⃣ Tính toán tổng tiền
    final double totalAmount = subtotal + shippingFee - discount;
    if (totalAmount < 0) {
      throw Exception('Tổng tiền không hợp lệ');
    }

    try {
      // 6️⃣ Lưu đơn hàng vào Firestore
      final orderRef = await _firestore.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Processing',
        'shippingAddress': shippingAddress.toMap(),
        'items': items,
        'paymentMethod': paymentMethod,
        'paymentDetail': {
          'subtotal': subtotal,
          'shippingFee': shippingFee,
          'discount': discount,
          'totalAmount': totalAmount,
        },
        'totalPrice': totalAmount, // Thêm totalPrice để dễ truy vấn
      });

      // 7️⃣ Gửi thông báo cho user
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': 'Đặt hàng thành công',
        'body':
            'Đơn hàng ${_formatCurrency(totalAmount)} đang được xử lý. Mã: ${orderRef.id}',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'order',
        'orderId': orderRef.id,
      });

      // 8️⃣ Log lịch sử đơn hàng
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('order_history')
          .doc(orderRef.id)
          .set({
        'orderId': orderRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'method': paymentMethod,
      });

      return orderRef.id;
    } catch (e, st) {
      // Log error for debugging
      print('🔴 OrderService.createOrder ERROR: $e');
      print(st.toString());

      // Write a diagnostic document so admins/devs can inspect failures
      try {
        await _firestore.collection('order_errors').add({
          'error': e.toString(),
          'stack': st.toString(),
          'userId': user?.uid,
          'items': items,
          'subtotal': subtotal,
          'shippingFee': shippingFee,
          'discount': discount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (logErr) {
        print('⚠️ Failed to write order_errors doc from OrderService: $logErr');
      }

      throw Exception('Lỗi tạo đơn hàng: ${e.toString()}');
    }
  }

  // ✅ Lấy lịch sử đơn hàng
  Future<List<OrderModel>> getOrderHistory() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy lịch sử đơn hàng: ${e.toString()}');
    }
  }

  // ✅ Lấy chi tiết đơn hàng
  Future<OrderModel?> getOrderDetail(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromMap(doc.id, doc.data() ?? {});
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết đơn hàng: ${e.toString()}');
    }
  }

  // ✅ Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'Cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Thông báo hủy đơn
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': 'Đơn hàng bị hủy',
        'body': 'Đơn hàng $orderId đã bị hủy. Lý do: $reason',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'order_cancelled',
        'orderId': orderId,
      });
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: ${e.toString()}');
    }
  }

  // 🎯 Hàm hỗ trợ format tiền
  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }
}
