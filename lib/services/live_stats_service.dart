import 'package:firebase_database/firebase_database.dart';

class LiveStatsService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Tăng số người xem khi vào trang
  void incrementView(String productId) {
    _db.ref('live_views/$productId').runTransaction((Object? post) {
      if (post == null) return Transaction.success(1);
      return Transaction.success((post as int) + 1);
    });
  }

  // Giảm số người xem khi thoát trang
  void decrementView(String productId) {
    _db.ref('live_views/$productId').runTransaction((Object? post) {
      if (post == null || (post as int) <= 0) return Transaction.success(0);
      return Transaction.success(post - 1);
    });
  }

  // Lấy Stream số lượng người xem theo thời gian thực
  Stream<DatabaseEvent> watchViews(String productId) {
    return _db.ref('live_views/$productId').onValue;
  }
}