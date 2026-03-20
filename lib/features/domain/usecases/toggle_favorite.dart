import '../entities/movie.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase();

  Movie call(Movie movie) {
    return movie.copyWith(isFavorite: !movie.isFavorite);
  }
}