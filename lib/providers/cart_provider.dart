import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

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

  Map<String, CartItem> get items => _items;

  int get totalItems => _items.values.fold(0, (s, it) => s + it.qty);

  double get totalPrice => _items.values.fold(0.0, (s, it) => s + it.qty * it.product.price);

  // CHỨC NĂNG: Thêm và Cập nhật lên Firebase
  void add(Product p, {int quantity = 1, String color = '', String size = ''}) async {
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

    // Lưu/Cập nhật dữ liệu vào collection 'cart' trên Firebase
    await _firestore.collection('cart').doc(cartItemId).set({
      'cartItemId': cartItemId,
      'productId': p.id,
      'title': p.title,
      'price': p.price,
      'imageUrl': p.images,
      'qty': _items[cartItemId]!.qty,
      'selectedColor': color,
      'selectedSize': size,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // CHỨC NĂNG: Xóa khỏi giỏ hàng Firebase
  void remove(String cartItemId) async {
    _items.remove(cartItemId);
    notifyListeners();

    await _firestore.collection('cart').doc(cartItemId).delete();
  }

  // CHỨC NĂNG: Thay đổi số lượng trên Firebase
  void changeQty(String cartItemId, int qty) async {
    if (_items.containsKey(cartItemId)) {
      if (qty <= 0) {
        remove(cartItemId);
      } else {
        _items[cartItemId]!.qty = qty;
        notifyListeners();

        await _firestore.collection('cart').doc(cartItemId).update({
          'qty': qty,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // CHỨC NĂNG: Xóa sạch giỏ hàng (sau khi thanh toán)
  void clear() async {
    _items.clear();
    notifyListeners();

    var snapshots = await _firestore.collection('cart').get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
