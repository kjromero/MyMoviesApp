import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/search_movies.dart';
import '../../data/repositories/movie_repository_impl.dart';

// ─── UseCase Providers ────────────────────────────────────────────
// Riverpod maneja la DI. No necesitás GetIt ni Hilt.

final getPopularMoviesUseCaseProvider = Provider<GetPopularMoviesUseCase>((ref) {
  return GetPopularMoviesUseCase(ref.watch(movieRepositoryProvider));
});

final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) {
  return SearchMoviesUseCase(ref.watch(movieRepositoryProvider));
});

// ─── Películas populares ──────────────────────────────────────────
// FutureProvider: maneja loading, error y data automáticamente.
// .family: permite pasar parámetros (page).
// .autoDispose: limpia cuando nadie escucha.

final popularMoviesProvider =
    FutureProvider.autoDispose.family<List<Movie>, int>((ref, page) async {
  final useCase = ref.watch(getPopularMoviesUseCaseProvider);
  return useCase(page: page);
});

// ─── Búsqueda ─────────────────────────────────────────────────────
// StateProvider para el query (reactivo, la UI lo escribe).

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.autoDispose<List<Movie>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.trim().isEmpty) return [];

  // Debounce manual: espera 500ms después del último cambio.
  await Future.delayed(const Duration(milliseconds: 500));

  // Si el query cambió durante el delay, cancelamos.
  if (ref.state.isLoading) return [];

  final useCase = ref.watch(searchMoviesUseCaseProvider);
  return useCase(query);
});

// ─── Detalle de película ──────────────────────────────────────────

final movieDetailProvider =
    FutureProvider.autoDispose.family<Movie, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getMovieDetail(movieId);
});

// ─── Paginación infinita ──────────────────────────────────────────
// Notifier para estado más complejo que un simple Future.

final paginatedMoviesProvider =
    AsyncNotifierProvider.autoDispose<PaginatedMoviesNotifier, List<Movie>>(
  PaginatedMoviesNotifier.new,
);

class PaginatedMoviesNotifier extends AutoDisposeAsyncNotifier<List<Movie>> {
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<Movie>> build() async {
    _currentPage = 1;
    _hasMore = true;
    final useCase = ref.watch(getPopularMoviesUseCaseProvider);
    return useCase(page: _currentPage);
  }

  Future<void> loadNextPage() async {
    if (!_hasMore) return;
    if (state.isLoading) return;

    _currentPage++;
    final useCase = ref.read(getPopularMoviesUseCaseProvider);
    final currentMovies = state.valueOrNull ?? [];

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final newMovies = await useCase(page: _currentPage);
      if (newMovies.isEmpty) _hasMore = false;
      return [...currentMovies, ...newMovies];
    });
  }

  bool get hasMore => _hasMore;
}