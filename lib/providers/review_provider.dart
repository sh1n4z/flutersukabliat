import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReviewModel> _productReviews = [];

  List<ReviewModel> get productReviews => _productReviews;

  // Lấy đánh giá của một sản phẩm cụ thể (Realtime)
  void fetchReviews(String productId) {
    _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _productReviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  // Thêm đánh giá mới
  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .add(review.toMap());
    } catch (e) {
      debugPrint("Error adding review: $e");
      rethrow;
    }
  }
}
