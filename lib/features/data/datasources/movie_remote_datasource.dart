import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/movie_model.dart';

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  return MovieRemoteDataSource(ref.watch(dioProvider));
});

class MovieRemoteDataSource {
  final Dio _dio;

  const MovieRemoteDataSource(this._dio);

  Future<List<MovieModel>> fetchPopularMovies({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {'query': query, 'page': page},
    );
    final results = response.data['results'] as List;
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<MovieModel> fetchMovieDetail(int id) async {
    final response = await _dio.get('/movie/$id');
    return MovieModel.fromJson(response.data);
  }
}