import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/datasources.dart';
import '../../data/repositories/desk_repository_impl.dart';
import '../../domain/repositories/desk_repository.dart';
import '../../domain/usecases/desk_usecases.dart';
import '../state/desks_state.dart';

final deskHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final deskDataSourceProvider = Provider<DeskDataSource>((ref) {
  final client = ref.watch(deskHttpClientProvider);
  return DeskApiDataSource(client: client);
});

final deskRepositoryProvider = Provider<DeskRepository>((ref) {
  final dataSource = ref.watch(deskDataSourceProvider);
  return DeskRepositoryImpl(dataSource: dataSource);
});

final getDesksUseCaseProvider = Provider<GetDesksUseCase>((ref) {
  final repository = ref.watch(deskRepositoryProvider);
  return GetDesksUseCase(repository);
});

final getDeskByIdUseCaseProvider = Provider<GetDeskByIdUseCase>((ref) {
  final repository = ref.watch(deskRepositoryProvider);
  return GetDeskByIdUseCase(repository);
});

final getFeaturedDesksUseCaseProvider =
    Provider<GetFeaturedDesksUseCase>((ref) {
  final repository = ref.watch(deskRepositoryProvider);
  return GetFeaturedDesksUseCase(repository);
});

final searchDesksUseCaseProvider = Provider<SearchDesksUseCase>((ref) {
  final repository = ref.watch(deskRepositoryProvider);
  return SearchDesksUseCase(repository);
});

class DesksNotifier extends StateNotifier<DesksState> {
  final GetDesksUseCase _getDesksUseCase;

  DesksNotifier(this._getDesksUseCase) : super(const DesksInitial());

  Future<void> loadDesks() async {
    state = const DesksLoading();

    final result = await _getDesksUseCase();

    result.fold(
      (failure) => state = DesksError(failure),
      (desks) => state = DesksLoaded(desks: desks),
    );
  }

  void filterByCategory(String? category) {
    if (state is DesksLoaded) {
      final currentState = state as DesksLoaded;
      state = currentState.copyWith(selectedCategory: category);
    }
  }

  void clearFilter() {
    if (state is DesksLoaded) {
      final currentState = state as DesksLoaded;
      state = DesksLoaded(
        desks: currentState.desks,
        selectedCategory: null,
      );
    }
  }

  Future<void> refresh() async {
    await loadDesks();
  }
}

final desksProvider = StateNotifierProvider<DesksNotifier, DesksState>(
  (ref) {
    final getDesksUseCase = ref.watch(getDesksUseCaseProvider);
    return DesksNotifier(getDesksUseCase);
  },
);

class DeskDetailNotifier extends StateNotifier<DeskDetailState> {
  final GetDeskByIdUseCase _getDeskByIdUseCase;

  DeskDetailNotifier(this._getDeskByIdUseCase)
      : super(const DeskDetailInitial());

  Future<void> loadDesk(String id) async {
    state = const DeskDetailLoading();

    final result = await _getDeskByIdUseCase(id);

    result.fold(
      (failure) => state = DeskDetailError(failure),
      (desk) => state = DeskDetailLoaded(desk: desk),
    );
  }

  void updateQuantity(int quantity) {
    if (state is DeskDetailLoaded && quantity > 0) {
      final currentState = state as DeskDetailLoaded;
      state = currentState.copyWith(quantity: quantity);
    }
  }

  void incrementQuantity() {
    if (state is DeskDetailLoaded) {
      final currentState = state as DeskDetailLoaded;
      state = currentState.copyWith(quantity: currentState.quantity + 1);
    }
  }

  void decrementQuantity() {
    if (state is DeskDetailLoaded) {
      final currentState = state as DeskDetailLoaded;
      if (currentState.quantity > 1) {
        state = currentState.copyWith(quantity: currentState.quantity - 1);
      }
    }
  }
}

final deskDetailProvider =
    StateNotifierProvider.family<DeskDetailNotifier, DeskDetailState, String>(
  (ref, deskId) {
    final getDeskByIdUseCase = ref.watch(getDeskByIdUseCaseProvider);
    return DeskDetailNotifier(getDeskByIdUseCase);
  },
);
