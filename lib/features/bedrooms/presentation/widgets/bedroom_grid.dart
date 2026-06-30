import 'package:flutter/material.dart';

import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/bedroom_entity.dart';

class BedroomGrid extends StatelessWidget {
  final List<Bedroom> bedrooms;
  final ValueChanged<Bedroom> onBedroomTap;
  final ValueChanged<Bedroom>? onAddToCart;
  final ValueChanged<Bedroom>? onWishlistToggle;
  final Set<String>? wishlistedIds;

  const BedroomGrid({
    super.key,
    required this.bedrooms,
    required this.onBedroomTap,
    this.onAddToCart,
    this.onWishlistToggle,
    this.wishlistedIds,
  });

  @override
  Widget build(BuildContext context) {
    if (bedrooms.isEmpty) {
      return const EmptyWidget(
        message: 'No bedrooms found',
        subtitle: 'Try adjusting your filters',
        icon: Icons.bedroom_parent_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: bedrooms.length,
      itemBuilder: (context, index) {
        final room = bedrooms[index];
        return ProductCard(
          name: room.name,
          description: room.description,
          price: room.price,
          originalPrice: room.originalPrice,
          imageUrl: room.imageUrl,
          rating: room.rating,
          reviewCount: room.reviewCount,
          inStock: room.inStock,
          isWishlisted: wishlistedIds?.contains(room.id) ?? false,
          onTap: () => onBedroomTap(room),
          onAddToCart: onAddToCart == null ? null : () => onAddToCart!(room),
          onWishlistToggle:
              onWishlistToggle == null ? null : () => onWishlistToggle!(room),
        );
      },
    );
  }
}
