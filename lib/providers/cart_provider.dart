import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../models/address_model.dart';

class CartItem {
  final Product product;
  int qty;
  final String selectedColor;
  final String selectedSize;

  CartItem({
    required this.product,
    this.qty = 1,
    required this.selectedColor,
    required this.selectedSize,
  });

  // Tạo ID duy nhất cho mỗi tổ hợp sản phẩm + biến thể
  String get cartItemId => "${product.id}_${selectedColor}_${selectedSize}";
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _cartCollection {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('cart');
    }
    return _firestore.collection('cart');
  }

  Map<String, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (s, it) => s + it.qty);

  double get totalPrice => _items.values.fold(0.0, (s, it) => s + it.qty * it.product.price);

  // CHỨC NĂNG: Thêm và Cập nhật lên Firebase
  Future<void> add(Product p, {int quantity = 1, String color = '', String size = ''}) async {
    final String cartItemId = "${p.id}_${color}_${size}";

    if (_items.containsKey(cartItemId)) {
      _items[cartItemId]!.qty += quantity;
    } else {
      _items[cartItemId] = CartItem(
        product: p,
        qty: quantity,
        selectedColor: color,
        selectedSize: size,
      );
    }
    notifyListeners();

    // Lưu/Cập nhật dữ liệu vào collection 'cart' (user-scoped when logged in)
    final user = _auth.currentUser;
    await _cartCollection.doc(cartItemId).set({
      'cartItemId': cartItemId,
      'productId': p.id,
      'title': p.title,
      'price': p.price,
      'imageUrl': p.images,
      'qty': _items[cartItemId]!.qty,
      'selectedColor': color,
      'selectedSize': size,
      'userId': user?.uid ?? null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // CHỨC NĂNG: Xóa khỏi giỏ hàng Firebase
  Future<void> remove(String cartItemId) async {
    _items.remove(cartItemId);
    notifyListeners();

    await _cartCollection.doc(cartItemId).delete();
  }

  // CHỨC NĂNG: Thay đổi số lượng trên Firebase
  Future<void> changeQty(String cartItemId, int qty) async {
    if (_items.containsKey(cartItemId)) {
      if (qty <= 0) {
        remove(cartItemId);
      } else {
        _items[cartItemId]!.qty = qty;
        notifyListeners();

        await _cartCollection.doc(cartItemId).update({
          'qty': qty,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // CHỨC NĂNG: Xóa sạch giỏ hàng (sau khi thanh toán)
  Future<void> clear() async {
    _items.clear();
    notifyListeners();

    var snapshots = await _cartCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // CHỨC NĂNG: Tạo đơn hàng (wrapper dùng OrderService)
  Future<String> placeOrder({
    required AddressModel shippingAddress,
    required String paymentMethod,
    double discount = 0,
    double shippingFee = 25000,
  }) async {
    final orderService = OrderService();

    // Chuẩn bị items
    final List<Map<String, dynamic>> orderItems = _items.values
        .map((item) => {
              'productId': item.product.id,
              'title': item.product.title,
              'price': item.product.price,
              'qty': item.qty,
              'imageUrl': item.product.images,
              'selectedColor': item.selectedColor,
              'selectedSize': item.selectedSize,
            })
        .toList();

    try {
      // Log payload for debugging
      print('➡️ CartProvider.placeOrder: creating order with ${orderItems.length} items, subtotal=$totalPrice, discount=$discount, shippingFee=$shippingFee');

      final orderId = await orderService.createOrder(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        items: orderItems,
        subtotal: totalPrice,
        discount: discount,
        shippingFee: shippingFee,
      );

      // Xóa cart sau khi tạo đơn
      await clear();
      print('✅ CartProvider.placeOrder: order created: $orderId');
      return orderId;
    } catch (e, st) {
      // Log error locally
      print('🔴 CartProvider.placeOrder ERROR: $e');
      print(st.toString());

      // Persist an error document for easier debugging in Firestore
      try {
        await _firestore.collection('order_errors').add({
          'error': e.toString(),
          'stack': st.toString(),
          'items': orderItems,
          'subtotal': totalPrice,
          'discount': discount,
          'shippingFee': shippingFee,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (logErr) {
        // If logging fails, print to console
        print('⚠️ Failed to write order_errors doc: $logErr');
      }

      // Rethrow so UI can show friendly message
      throw Exception('Lỗi khi đặt hàng: ${e.toString()}');
    }
  }
}
