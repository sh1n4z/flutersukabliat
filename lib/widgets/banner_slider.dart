import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_slider.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  int _bannerCount = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients && _bannerCount > 0) {
        _currentBannerPage++;
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color goldAccent = Color(0xFFC5A059);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').orderBy('order').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 200);

        final banners = snapshot.data!.docs.map((doc) =>
            BannerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

        _bannerCount = banners.length;

        if (_bannerCount == 0) return const SizedBox.shrink();

        return Stack(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: 1000, // Để hiệu ứng lướt vô tận
                onPageChanged: (index) => setState(() => _currentBannerPage = index),
                itemBuilder: (context, index) {
                  final banner = banners[index % _bannerCount];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white, // Nền trắng để làm nổi bật ảnh quảng cáo
                      borderRadius: BorderRadius.circular(20), // Bo góc sâu cho đồng bộ với Card
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0), // Tạo viền trắng quanh ảnh banner
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            banner.imageUrl,
                            fit: BoxFit.cover, // Banner nên dùng cover để lấp đầy khung
                          ),
                        ),
                      ),
                    ),
                  );
                },

              ),
            ),
            // Các chấm chỉ số ảnh (Dots Indicator)
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_bannerCount, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: (_currentBannerPage % _bannerCount) == index ? 20 : 8,
                    decoration: BoxDecoration(
                      color: (_currentBannerPage % _bannerCount) == index ? goldAccent : Colors.white54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            )
          ],
        );
      },
    );
  }
}
