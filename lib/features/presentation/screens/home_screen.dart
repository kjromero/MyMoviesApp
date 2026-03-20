import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch: se suscribe y rebuild automático cuando cambia.
    final moviesAsync = ref.watch(paginatedMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas populares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: moviesAsync.when(
        // .when: el pattern matching de Riverpod.
        // Maneja loading, error y data sin boilerplate.
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(paginatedMoviesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (movies) => MovieGrid(
          movies: movies,
          onLoadMore: () {
            ref.read(paginatedMoviesProvider.notifier).loadNextPage();
          },
          onMovieTap: (movie) => context.push('/movie/${movie.id}'),
        ),
      ),
    );
  }
}