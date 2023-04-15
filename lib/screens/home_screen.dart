import 'package:films_application/providers/movie_provider.dart';
import 'package:films_application/utils/search/search_movie.dart';
import 'package:films_application/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Peliculas en cine'),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () => showSearch(
                    context: context, delegate: MovieSearchDelegate()),
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Tarjetas Principales
              CardSwiper(movies: moviesProvider.onDisplayMovie),

              // Listado Horizontal de peliculas
              MovieSlider(
                  movies: moviesProvider.onDisplayPopularMovie,
                  title: 'Populares',
                  onNextPage: () => moviesProvider.getPopularMovies()),
            ],
          ),
        ));
  }
}
