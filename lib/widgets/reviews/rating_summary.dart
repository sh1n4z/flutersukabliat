import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; 

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: Row(
        children: [
          _buildAverageRating(context),
          const SizedBox(width: 32),
          Expanded(child: _buildRatingDistribution()),
        ],
      ),
    );
  }

  Widget _buildAverageRating(BuildContext context) {
    return Column(
      children: [
        Text(
          averageRating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.ebonyDark),
        ),
        const SizedBox(height: 4),
        _buildStarRating(averageRating, size: 18),
        const SizedBox(height: 8),
        Text('$totalReviews REVIEW', 
          style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildStarRating(double rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon = Icons.star_rounded;
        Color color = AppColors.woodAccent;
        if (index + 1 > rating) {
          icon = Icons.star_outline_rounded;
          color = Colors.grey.shade300;
        }
        return Icon(icon, color: color, size: size);
      }),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      children: List.generate(5, (index) {
        final star = 5 - index;
        final count = ratingDistribution[star] ?? 0;
        final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
        return _buildDistributionBar(star, percentage);
      }).toList(),
    );
  }

  Widget _buildDistributionBar(int star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ebonyDark)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.woodAccent),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
