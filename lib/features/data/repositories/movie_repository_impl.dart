import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(ref.watch(movieRemoteDataSourceProvider));
});

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  const MovieRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final models = await _remoteDataSource.fetchPopularMovies(page: page);
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final models = await _remoteDataSource.searchMovies(query, page: page);
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      final logger = Logger();
      throw ServerFailure(
        e.response?.statusMessage ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Movie> getMovieDetail(int id) async {
    try {
      final model = await _remoteDataSource.fetchMovieDetail(id);
      return model.toEntity();
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.statusMessage ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      );
    }
  }
}