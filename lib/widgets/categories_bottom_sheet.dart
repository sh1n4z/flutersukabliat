import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../screens/category/category_screen.dart';

class CategoriesBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CategoriesBottomSheetContent(),
    );
  }
}

class _CategoriesBottomSheetContent extends StatefulWidget {
  const _CategoriesBottomSheetContent();

  @override
  State<_CategoriesBottomSheetContent> createState() => _CategoriesBottomSheetContentState();
}

class _CategoriesBottomSheetContentState extends State<_CategoriesBottomSheetContent> {
  RangeValues _currentRangeValues = const RangeValues(0, 5000000); // Mặc định 0 - 5tr

  /// Helper function: Convert category ID string to IconData
  IconData _getCategoryIcon(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'living':
        return Icons.chair_rounded;
      case 'bedroom':
        return Icons.bed_rounded;
      case 'dining':
      case 'tables':
        return Icons.restaurant_rounded;
      case 'office':
      case 'storage':
        return Icons.work_rounded;
      case 'decor':
        return Icons.lightbulb_outline;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DANH MỤC',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khám phá các mục yêu thích',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 🛠️ BỘ LỌC GIÁ (MỚI)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KHOẢNG GIÁ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.woodAccent)),
                    Text(
                      '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_currentRangeValues.start)} - ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_currentRangeValues.end)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ebonyDark),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 50000000, // Max 50 triệu
                  divisions: 30,
                  activeColor: AppColors.woodAccent,
                  inactiveColor: AppColors.greyLight,
                  labels: RangeLabels(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_currentRangeValues.start),
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_currentRangeValues.end),
                  ),
                  onChanged: (RangeValues values) => setState(() => _currentRangeValues = values),
                ),
              ],
            ),
          ),

          // Categories Grid (with Firebase StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('sortOrder', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                // Error handling
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lỗi tải danh mục',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.woodAccent),
                    ),
                  );
                }

                // Parse data from Firebase
                try {
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không có danh mục nào',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>?;

                      if (data == null) {
                        return const SizedBox.shrink();
                      }

                      final categoryId = doc.id;
                      final categoryName =
                          data['name']?.toString() ?? 'Unknown';
                      final iconString =
                          data['icon']?.toString() ?? 'category';
                      final productCount =
                          (data['productCount'] ?? 0) as int;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            try {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryScreen(
                                    category: categoryId,
                                    minPrice: _currentRangeValues.start,
                                    maxPrice: _currentRangeValues.end,
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi điều hướng: ${e.toString()}',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.greyLight,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon in colored circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(iconString),
                                    color: AppColors.ebonyDark,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Category name
                                Text(
                                  categoryName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Item count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$productCount mục',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.woodAccent
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 12,
                                        color: AppColors.woodAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } catch (e) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lỗi xử lý dữ liệu: $e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          // Bottom action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      category: 'all',
                      minPrice: _currentRangeValues.start,
                      maxPrice: _currentRangeValues.end,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ebonyMedium,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Xem Tất Cả Sản Phẩm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
