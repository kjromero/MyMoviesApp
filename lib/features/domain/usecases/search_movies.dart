import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class SearchMoviesUseCase {
  final MovieRepository _repository;

  const SearchMoviesUseCase(this._repository);

  Future<List<Movie>> call(String query, {int page = 1}) {
    return _repository.searchMovies(query, page: page);
  }
}