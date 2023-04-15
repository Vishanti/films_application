import 'dart:async';
import 'dart:convert';
import 'package:films_application/helpers/debouncer.dart';
import 'package:films_application/models/models.dart';
import 'package:films_application/models/search_movie_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = 'c380c5891054af5c7e2a4a2a4d58fdbc';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovie = [];
  List<Movie> onDisplayPopularMovie = [];
  Map<int, List<Cast>> moviesCast = {};
  int _popularPage = 0;

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  MoviesProvider() {
    print('Movie Provider inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  ///Metodo que recibe el endpoint para hacer la llamada http
  Future<String> getJsonEncodeData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});

    final response = await http.get(url);
    return response.body;
  }

  ///Metodo que recibe el response de la llamada al servicio y lo guarda en onDisplayMovie
  getOnDisplayMovies() async {
    final jsonEncodeData = await getJsonEncodeData('3/movie/now_playing');
    final nowPlayingResponse =
        NowPlayingResponse.fromJson(json.decode(jsonEncodeData));
    onDisplayMovie = nowPlayingResponse.results;
    notifyListeners();
  }

  ///Metodo que recibe el response de la llamada al servicio y lo guarda en onDisplayPopularMovie
  getPopularMovies() async {
    _popularPage++;
    final jsonEncodeData =
        await getJsonEncodeData('3/movie/popular', _popularPage);
    final popularResponse =
        PopularResponse.fromJson(json.decode(jsonEncodeData));
    onDisplayPopularMovie = [
      ...onDisplayPopularMovie,
      ...popularResponse.results
    ];
    notifyListeners();
  }

  Future<List<Cast>> getMoviesCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    final jsonEncodeData = await getJsonEncodeData('3/movie/$movieId/credits');
    final creditsResponse =
        CreditsResponse.fromJson(json.decode(jsonEncodeData));

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});
    final response = await http.get(url);
    final searchMovieResponse =
        SearchMovieResponse.fromJson(json.decode(response.body));
    return searchMovieResponse.results;
  }

  ///Metodo que envia lo escrito con un tiempo asignado de escritura
  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final result = await searchMovie(value);
      _suggestionStreamController.add(result);
    };
    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });
    Future.delayed(const Duration(milliseconds: 301))
        .then((value) => timer.cancel());
  }
}
