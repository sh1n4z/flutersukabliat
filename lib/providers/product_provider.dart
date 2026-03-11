import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';

  List<Product> get products => _filteredProducts.isEmpty && _searchQuery.isEmpty ? _allProducts : _filteredProducts;
  String get searchQuery => _searchQuery;

  // ✅ Lấy danh sách sản phẩm từ Firestore
  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _allProducts = snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
      _filteredProducts = List.from(_allProducts);
      notifyListeners();
    } catch (e) {
      print('🔴 Lỗi lấy sản phẩm: $e');
      rethrow;
    }
  }

  // ✅ Thêm sản phẩm mới
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      final newProduct = product;
      // Tạo product mới với ID từ Firestore
      final productWithId = Product(
        id: docRef.id,
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        images: newProduct.images,
        category: newProduct.category,
        rating: newProduct.rating,
        reviews: newProduct.reviews,
      );
      
      _allProducts.add(productWithId);
      _filteredProducts = List.from(_allProducts);
      notifyListeners();
      
      return docRef.id;
    } catch (e) {
      print('🔴 Lỗi thêm sản phẩm: $e');
      rethrow;
    }
  }

  // ✅ Cập nhật sản phẩm
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      
      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = product;
        _filteredProducts = List.from(_allProducts);
        notifyListeners();
      }
    } catch (e) {
      print('🔴 Lỗi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  // ✅ Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      
      _allProducts.removeWhere((p) => p.id == productId);
      _filteredProducts = List.from(_allProducts);
      notifyListeners();
    } catch (e) {
      print('🔴 Lỗi xóa sản phẩm: $e');
      rethrow;
    }
  }

  // ✅ Tìm kiếm sản phẩm (local filter)
  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()) ||
                        p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ✅ Lấy sản phẩm theo ID
  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Clear cache
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }
}
