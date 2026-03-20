import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar películas...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Actualiza el StateProvider. searchResultsProvider
            // reacciona automáticamente porque watch(searchQueryProvider).
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (movies) {
          if (movies.isEmpty && _controller.text.isNotEmpty) {
            return const Center(child: Text('No se encontraron resultados'));
          }
          if (movies.isEmpty) {
            return const Center(child: Text('Escribe para buscar'));
          }
          return MovieGrid(
            movies: movies,
            onMovieTap: (movie) => context.push('/movie/${movie.id}'),
          );
        },
      ),
    );
  }
}