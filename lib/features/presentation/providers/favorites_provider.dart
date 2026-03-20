import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/toggle_favorite.dart';

// ─── UseCase Provider ─────────────────────────────────────────────

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return const ToggleFavoriteUseCase();
});

// ─── Notifier para favoritos ──────────────────────────────────────
// NotifierProvider: para estado síncrono complejo.

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int movieId) {
    if (state.contains(movieId)) {
      state = {...state}..remove(movieId);
    } else {
      state = {...state, movieId};
    }
  }

  bool isFavorite(int movieId) => state.contains(movieId);
}

// ─── Provider derivado: ¿es favorita esta película? ───────────────
// .family con movieId. Se recalcula solo cuando cambian los favoritos.

final isMovieFavoriteProvider = Provider.family<bool, int>((ref, movieId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(movieId);
});