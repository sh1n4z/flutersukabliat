import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0, name: 'đ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          // Ảnh sản phẩm lớn
          Hero(
            tag: item.cartItemId,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                item.product.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 13, 
                          color: AppColors.ebonyDark,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey.shade300, size: 20),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.selectedColor} | ${item.selectedSize}",
                  style: TextStyle(color: AppColors.woodAccent.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(item.product.price),
                      style: const TextStyle(color: AppColors.ebonyDark, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    // Tăng giảm số lượng (Katinat style)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _qtyAction(Icons.remove, () => onQuantityChanged(item.qty - 1)),
                          Text(
                            "${item.qty}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.ebonyDark),
                          ),
                          _qtyAction(Icons.add, () => onQuantityChanged(item.qty + 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 14, color: AppColors.ebonyDark),
      ),
    );
  }
}
