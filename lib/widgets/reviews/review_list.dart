import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/review_model.dart';
import '../../theme/app_colors.dart';

class ReviewList extends StatelessWidget {
  final List<ReviewModel> reviews;

  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("Chưa có đánh giá nào cho sản phẩm này", 
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      );
    }

    return ListView.separated(
      itemCount: reviews.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (context, index) => Divider(
        height: 32, 
        thickness: 1, 
        color: AppColors.ebonyDark.withOpacity(0.05),
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        return ReviewListItem(review: reviews[index]);
      },
    );
  }
}

class ReviewListItem extends StatelessWidget {
  final ReviewModel review;

  const ReviewListItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                backgroundImage: review.userAvatar.isNotEmpty 
                    ? NetworkImage(review.userAvatar) 
                    : null,
                child: review.userAvatar.isEmpty 
                    ? const Icon(Icons.person, color: Colors.grey, size: 20) 
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ebonyDark),
                    ),
                    const SizedBox(height: 2),
                    _buildStarRating(review.rating),
                  ],
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(review.date),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14, 
              color: AppColors.ebonyDark.withOpacity(0.8), 
              height: 1.5,
            ),
          ),
          if (review.images.isNotEmpty) _buildReviewImages(),
          const SizedBox(height: 16),
          // Nút "Hữu ích" tối giản phong cách Ebony
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text("Hữu ích", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < rating ? AppColors.woodAccent : Colors.grey.shade300,
          size: 14,
        );
      }),
    );
  }

  Widget _buildReviewImages() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                review.images[index],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 80, 
                  color: AppColors.background,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
