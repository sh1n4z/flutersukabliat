// migrated to feature folder
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: const Center(child: Text('Favorites list')),
    );
  }
}
