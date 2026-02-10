import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Product> _items = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Product> get items => [..._items];

  bool isFavorite(String productId) {
    return _items.any((p) => p.id == productId);
  }

  FavoriteProvider() {
    _loadFavorites();
  }

  // Tải danh sách yêu thích từ Firebase khi khởi tạo
  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _items.clear();
      for (var doc in snapshot.docs) {
        _items.add(Product.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    } catch (e) {
      print("Lỗi tải favorites: $e");
    }
  }

  // Thêm hoặc xóa sản phẩm khỏi danh sách yêu thích
  Future<void> toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((p) => p.id == product.id);
    
    if (index >= 0) {
      // Đã có -> Xóa
      _items.removeAt(index);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id)
          .delete();
    } else {
      // Chưa có -> Thêm
      _items.add(product);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id)
          .set(product.toMap());
    }
    notifyListeners();
  }
}
