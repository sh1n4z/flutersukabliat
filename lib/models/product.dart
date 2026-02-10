class Product {
  final String id;
  final String title; // Đã đổi tên từ 'name' sang 'title' để khớp với Firestore
  final String description;
  final double price;
  final List<String> images; // Đã đổi từ 1 ảnh sang List ảnh
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
  });

  // Giúp lấy nhanh 1 tấm ảnh đại diện
  String get imageUrl => images.isNotEmpty ? images[0] : '';

  factory Product.fromMap(String id, Map<String, dynamic> m) {
    List<String> imgs = [];
    if (m['images'] != null) {
      imgs = List<String>.from(m['images']);
    } else if (m['imageUrl'] != null) {
      imgs = [m['imageUrl'].toString()];
    }

    return Product(
      id: id,
      title: m['title']?.toString() ?? m['name']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      price: (m['price'] ?? 0).toDouble(),
      category: m['category']?.toString() ?? '',
      images: imgs,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'price': price,
    'images': images,
    'category': category,
  };
}
