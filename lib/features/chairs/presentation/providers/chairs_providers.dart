import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/datasources.dart';
import '../../data/repositories/chair_repository_impl.dart';
import '../../domain/repositories/chair_repository.dart';
import '../../domain/usecases/chair_usecases.dart';
import '../state/chairs_state.dart';

final chairHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final chairDataSourceProvider = Provider<ChairDataSource>((ref) {
  final client = ref.watch(chairHttpClientProvider);
  return ChairApiDataSource(client: client);
});

final chairRepositoryProvider = Provider<ChairRepository>((ref) {
  final dataSource = ref.watch(chairDataSourceProvider);
  return ChairRepositoryImpl(dataSource: dataSource);
});

final getChairsUseCaseProvider = Provider<GetChairsUseCase>((ref) {
  final repository = ref.watch(chairRepositoryProvider);
  return GetChairsUseCase(repository);
});

final getChairByIdUseCaseProvider = Provider<GetChairByIdUseCase>((ref) {
  final repository = ref.watch(chairRepositoryProvider);
  return GetChairByIdUseCase(repository);
});

final getFeaturedChairsUseCaseProvider =
    Provider<GetFeaturedChairsUseCase>((ref) {
  final repository = ref.watch(chairRepositoryProvider);
  return GetFeaturedChairsUseCase(repository);
});

final searchChairsUseCaseProvider = Provider<SearchChairsUseCase>((ref) {
  final repository = ref.watch(chairRepositoryProvider);
  return SearchChairsUseCase(repository);
});

class ChairsNotifier extends StateNotifier<ChairsState> {
  final GetChairsUseCase _getChairsUseCase;

  ChairsNotifier(this._getChairsUseCase) : super(const ChairsInitial());

  Future<void> loadChairs() async {
    state = const ChairsLoading();

    final result = await _getChairsUseCase();

    result.fold(
      (failure) => state = ChairsError(failure),
      (chairs) => state = ChairsLoaded(chairs: chairs),
    );
  }

  void filterByCategory(String? category) {
    if (state is ChairsLoaded) {
      final currentState = state as ChairsLoaded;
      state = currentState.copyWith(
        selectedCategory: category,
      );
    }
  }

  void clearFilter() {
    if (state is ChairsLoaded) {
      final currentState = state as ChairsLoaded;
      state = ChairsLoaded(
        chairs: currentState.chairs,
        selectedCategory: null,
      );
    }
  }

  Future<void> refresh() async {
    await loadChairs();
  }
}

final chairsProvider = StateNotifierProvider<ChairsNotifier, ChairsState>(
  (ref) {
    final getChairsUseCase = ref.watch(getChairsUseCaseProvider);
    return ChairsNotifier(getChairsUseCase);
  },
);

class ChairDetailNotifier extends StateNotifier<ChairDetailState> {
  final GetChairByIdUseCase _getChairByIdUseCase;

  ChairDetailNotifier(this._getChairByIdUseCase)
      : super(const ChairDetailInitial());

  Future<void> loadChair(String id) async {
    state = const ChairDetailLoading();

    final result = await _getChairByIdUseCase(id);

    result.fold(
      (failure) => state = ChairDetailError(failure),
      (chair) => state = ChairDetailLoaded(chair: chair),
    );
  }

  void updateQuantity(int quantity) {
    if (state is ChairDetailLoaded && quantity > 0) {
      final currentState = state as ChairDetailLoaded;
      state = currentState.copyWith(quantity: quantity);
    }
  }

  void incrementQuantity() {
    if (state is ChairDetailLoaded) {
      final currentState = state as ChairDetailLoaded;
      state = currentState.copyWith(quantity: currentState.quantity + 1);
    }
  }

  void decrementQuantity() {
    if (state is ChairDetailLoaded) {
      final currentState = state as ChairDetailLoaded;
      if (currentState.quantity > 1) {
        state = currentState.copyWith(quantity: currentState.quantity - 1);
      }
    }
  }
}

final chairDetailProvider =
    StateNotifierProvider.family<ChairDetailNotifier, ChairDetailState, String>(
  (ref, chairId) {
    final getChairByIdUseCase = ref.watch(getChairByIdUseCaseProvider);
    return ChairDetailNotifier(getChairByIdUseCase);
  },
);
