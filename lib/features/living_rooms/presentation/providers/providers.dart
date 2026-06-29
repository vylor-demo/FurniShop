import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/living_room_api_datasource.dart';
import '../../data/datasources/living_room_datasource.dart';
import '../../data/repositories/living_room_repository_impl.dart';
import '../../domain/repositories/living_room_repository.dart';
import '../../domain/usecases/living_room_usecases.dart';
import '../state/state.dart';

final livingRoomHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final livingRoomDataSourceProvider = Provider<LivingRoomDataSource>((ref) {
  final client = ref.watch(livingRoomHttpClientProvider);
  return LivingRoomApiDataSource(client: client);
});

final livingRoomRepositoryProvider = Provider<LivingRoomRepository>((ref) {
  final dataSource = ref.watch(livingRoomDataSourceProvider);
  return LivingRoomRepositoryImpl(dataSource: dataSource);
});

final getLivingRoomsUseCaseProvider = Provider<GetLivingRoomsUseCase>((ref) {
  final repository = ref.watch(livingRoomRepositoryProvider);
  return GetLivingRoomsUseCase(repository);
});

final getLivingRoomByIdUseCaseProvider =
    Provider<GetLivingRoomByIdUseCase>((ref) {
  final repository = ref.watch(livingRoomRepositoryProvider);
  return GetLivingRoomByIdUseCase(repository);
});

final getFeaturedLivingRoomsUseCaseProvider =
    Provider<GetFeaturedLivingRoomsUseCase>((ref) {
  final repository = ref.watch(livingRoomRepositoryProvider);
  return GetFeaturedLivingRoomsUseCase(repository);
});

final searchLivingRoomsUseCaseProvider =
    Provider<SearchLivingRoomsUseCase>((ref) {
  final repository = ref.watch(livingRoomRepositoryProvider);
  return SearchLivingRoomsUseCase(repository);
});

class LivingRoomsNotifier extends StateNotifier<LivingRoomsState> {
  final GetLivingRoomsUseCase _getLivingRoomsUseCase;

  LivingRoomsNotifier(this._getLivingRoomsUseCase)
      : super(const LivingRoomsInitial());

  Future<void> loadLivingRooms() async {
    state = const LivingRoomsLoading();

    final result = await _getLivingRoomsUseCase();

    result.fold(
      (failure) => state = LivingRoomsError(failure),
      (rooms) => state = LivingRoomsLoaded(rooms: rooms),
    );
  }

  void filterByCategory(String? category) {
    if (state is LivingRoomsLoaded) {
      final currentState = state as LivingRoomsLoaded;
      state = currentState.copyWith(selectedCategory: category);
    }
  }

  Future<void> refresh() async {
    await loadLivingRooms();
  }
}

final livingRoomsProvider =
    StateNotifierProvider<LivingRoomsNotifier, LivingRoomsState>((ref) {
  final useCase = ref.watch(getLivingRoomsUseCaseProvider);
  return LivingRoomsNotifier(useCase);
});

class LivingRoomDetailNotifier extends StateNotifier<LivingRoomDetailState> {
  final GetLivingRoomByIdUseCase _getLivingRoomByIdUseCase;

  LivingRoomDetailNotifier(this._getLivingRoomByIdUseCase)
      : super(const LivingRoomDetailInitial());

  Future<void> loadLivingRoom(String id) async {
    state = const LivingRoomDetailLoading();

    final result = await _getLivingRoomByIdUseCase(id);

    result.fold(
      (failure) => state = LivingRoomDetailError(failure),
      (room) => state = LivingRoomDetailLoaded(livingRoom: room),
    );
  }

  void updateQuantity(int quantity) {
    if (state is LivingRoomDetailLoaded) {
      final currentState = state as LivingRoomDetailLoaded;
      state = currentState.copyWith(quantity: quantity);
    }
  }
}

final livingRoomDetailProvider = StateNotifierProvider.family<
    LivingRoomDetailNotifier,
    LivingRoomDetailState,
    String>((ref, roomId) {
  final useCase = ref.watch(getLivingRoomByIdUseCaseProvider);
  return LivingRoomDetailNotifier(useCase);
});
