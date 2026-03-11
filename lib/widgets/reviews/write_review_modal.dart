import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

void showWriteReviewModal(BuildContext context, {required String productId, required Function(double rating, String comment) onSubmit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: WriteReviewModal(
          controller: controller, 
          productId: productId,
          onSubmit: onSubmit,
        ),
      ),
    ),
  );
}

class WriteReviewModal extends StatefulWidget {
  final ScrollController controller;
  final String productId;
  final Function(double rating, String comment) onSubmit;

  const WriteReviewModal({
    super.key, 
    required this.controller, 
    required this.productId,
    required this.onSubmit,
  });

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  int _rating = 0;
  final _textController = TextEditingController();

  final Map<int, String> _ratingTextMap = {
    1: 'Tệ',
    2: 'Không hài lòng',
    3: 'Bình thường',
    4: 'Hài lòng',
    5: 'Tuyệt vời'
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.controller,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ĐÁNH GIÁ SẢN PHẨM',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.ebonyDark, letterSpacing: 2),
          ),
          const SizedBox(height: 32),
          _buildRatingSelector(),
          const SizedBox(height: 32),
          _buildReviewTextField(),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final star = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = star),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 44,
                  color: star <= _rating ? AppColors.woodAccent : Colors.grey[200],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        if (_rating > 0)
          Text(
            _ratingTextMap[_rating]!.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.woodAccent, letterSpacing: 1),
          ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return TextField(
      controller: _textController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: AppColors.ebonyDark),
      decoration: InputDecoration(
        hintText: 'Chia sẻ cảm nhận của bạn về sản phẩm...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isReady = _rating > 0;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isReady ? () {
          widget.onSubmit(_rating.toDouble(), _textController.text);
          Navigator.pop(context);
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ebonyDark,
          disabledBackgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'GỬI ĐÁNH GIÁ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
