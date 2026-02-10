class BannerModel {
  final String id;
  final String imageUrl;
  final String title;

  BannerModel({required this.id, required this.imageUrl, required this.title});

  factory BannerModel.fromMap(String id, Map<String, dynamic> m) {
    return BannerModel(
      id: id,
      imageUrl: m['imageUrl'] ?? '',
      title: m['title'] ?? '',
    );
  }
}
