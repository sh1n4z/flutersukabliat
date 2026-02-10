import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

class OrderItem {
  final String title;
  final double price;
  final int qty;
  final List<String> imageUrl;
  final String productId;
  final String selectedColor;
  final String selectedSize;

  OrderItem({
    required this.title,
    required this.price,
    required this.qty,
    required this.imageUrl,
    required this.productId,
    required this.selectedColor,
    required this.selectedSize,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    List<String> imgs = [];
    if (map['imageUrl'] is List) {
      imgs = List<String>.from(map['imageUrl']);
    } else if (map['imageUrl'] is String) {
      imgs = [map['imageUrl']];
    }

    return OrderItem(
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      qty: map['qty'] ?? 0,
      imageUrl: imgs,
      productId: map['productId'] ?? '',
      selectedColor: map['selectedColor'] ?? 'N/A',
      selectedSize: map['selectedSize'] ?? 'N/A',
    );
  }
}

class OrderModel {
  final String id;
  final String userId; // Thêm userId
  final DateTime orderDate;
  final double totalPrice;
  final String status;
  final List<OrderItem> items;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final Map<String, dynamic> paymentDetail;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.paymentDetail,
    this.cancellationReason,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    List<OrderItem> parsedItems = [];
    if (data['items'] != null && data['items'] is List) {
      parsedItems = (data['items'] as List).map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i))).toList();
    }

    double total = (data['totalPrice'] ?? 0).toDouble();
    if (total == 0 && data['paymentDetail'] != null) {
      total = (data['paymentDetail']['totalAmount'] ?? 0).toDouble();
    }

    return OrderModel(
      id: id,
      userId: data['userId'] ?? '', // Lấy userId từ Firebase
      orderDate: data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : DateTime.now(),
      totalPrice: total,
      status: data['status'] ?? 'Processing',
      items: parsedItems,
      shippingAddress: AddressModel.fromMap('', data['shippingAddress'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? 'COD',
      paymentDetail: Map<String, dynamic>.from(data['paymentDetail'] ?? {}),
      cancellationReason: data['cancellationReason'],
    );
  }
}
