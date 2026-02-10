import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tông màu Gỗ Mun
    const Color ebonyBlack = Color(0xFF1A1A1A);
    const Color goldAccent = Color(0xFFC5A059);
    const Color darkBackground = Color(0xFF121212);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text("BỘ SƯU TẬP",
            style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: ebonyBlack,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Lỗi kết nối", style: TextStyle(color: Colors.white)));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: goldAccent));
          }

          final allProducts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Product.fromMap(doc.id, data);
          }).toList();

          final categories = allProducts.map((e) => e.category).toSet().toList();

          if (categories.isEmpty) {
            return const Center(child: Text("Chưa có danh mục nào", style: TextStyle(color: Colors.grey)));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: categories.map((cat) {
              final itemsInCategory = allProducts.where((p) => p.category == cat).toList();

              return Card(
                color: ebonyBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  collapsedIconColor: goldAccent,
                  iconColor: goldAccent,
                  title: Text(
                    cat.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                      letterSpacing: 1.1,
                    ),
                  ),
                  children: [
                    Container(
                      height: 280,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: itemsInCategory.length,
                        itemBuilder: (_, i) => Container(
                          width: 200,
                          margin: const EdgeInsets.only(left: 12),
                          child: ProductCard(
                            product: itemsInCategory[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(product: itemsInCategory[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
