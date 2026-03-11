class Product {
  final String id;
  final String title; // Đã đổi tên từ 'name' sang 'title' để khớp với Firestore
  final String description;
  final double price;
  final List<String> images; // Đã đổi từ 1 ảnh sang List ảnh
  final String category;
  final List<dynamic> colors; // Danh sách màu sắc từ Firebase
  final List<dynamic> sizes; // Danh sách kích cỡ từ Firebase
  final double rating; // Đánh giá sao (React: rating)
  final int reviews; // Số lượng đánh giá (React: reviews)

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    this.colors = const [],
    this.sizes = const [],
    this.rating = 0.0,
    this.reviews = 0,
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

    // Parse colors một cách an toàn
    List<dynamic> colors = [];
    if (m['colors'] != null && m['colors'] is List) {
      colors = List<dynamic>.from(m['colors']);
    }

    // Parse sizes một cách an toàn
    List<dynamic> sizes = [];
    if (m['sizes'] != null && m['sizes'] is List) {
      sizes = List<dynamic>.from(m['sizes']);
    }

    return Product(
      id: id,
      title: m['title']?.toString() ?? m['name']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      price: (m['price'] ?? 0).toDouble(),
      category: m['category']?.toString() ?? '',
      images: imgs,
      colors: colors,
      sizes: sizes,
      rating: (m['rating'] ?? 0).toDouble(),
      reviews: (m['reviews'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'price': price,
    'images': images,
    'category': category,
    'colors': colors,
    'sizes': sizes,
    'rating': rating,
    'reviews': reviews,
  };
}
