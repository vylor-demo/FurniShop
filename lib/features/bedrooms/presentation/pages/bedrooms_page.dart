import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/state_widgets.dart' as core;
import '../providers/bedrooms_providers.dart';
import '../state/bedrooms_state.dart';
import '../widgets/bedroom_grid.dart';
import '../widgets/category_filter.dart';

class BedroomsPage extends ConsumerStatefulWidget {
  const BedroomsPage({super.key});

  @override
  ConsumerState<BedroomsPage> createState() => _BedroomsPageState();
}

class _BedroomsPageState extends ConsumerState<BedroomsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bedroomsProvider.notifier).loadBedrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bedroomsProvider);

    return AppScaffold(
      title: 'Bedrooms',
      actions: const [
        Icon(Icons.search),
        SizedBox(width: 8),
        Icon(Icons.shopping_cart_outlined),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.read(bedroomsProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(BedroomsState state) {
    return switch (state) {
      BedroomsInitial() => const core.LoadingWidget(message: 'Loading...'),
      BedroomsLoading() => const core.LoadingWidget(message: 'Loading bedrooms...'),
      BedroomsLoaded(:final bedrooms, :final selectedCategory, :final categories, :final filteredBedrooms) =>
        _buildLoaded(
          bedrooms: bedrooms,
          selectedCategory: selectedCategory,
          categories: categories,
          filteredBedrooms: filteredBedrooms,
        ),
      BedroomsError(:final message) => core.ErrorWidget(
          message: message,
          onRetry: () => ref.read(bedroomsProvider.notifier).loadBedrooms(),
        ),
    };
  }

  Widget _buildLoaded({
    required List bedrooms,
    required List filteredBedrooms,
    required List<String> categories,
    required String? selectedCategory,
  }) {
    return Column(
      children: [
        BedroomCategoryFilter(
          categories: categories,
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            ref.read(bedroomsProvider.notifier).filterByCategory(category);
          },
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filteredBedrooms.length} results',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Sort'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BedroomGrid(
            bedrooms: filteredBedrooms.cast(),
            onBedroomTap: (_) {},
            onAddToCart: (item) {
              _showAdded(context, item.name);
            },
          ),
        ),
      ],
    );
  }

  void _showAdded(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
