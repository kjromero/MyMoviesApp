import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetPopularMoviesUseCase {
  final MovieRepository _repository;

  const GetPopularMoviesUseCase(this._repository);

  Future<List<Movie>> call({int page = 1}) {
    return _repository.getPopularMovies(page: page);
  }
}