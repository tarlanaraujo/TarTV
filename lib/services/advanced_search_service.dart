import 'package:flutter/foundation.dart';
import '../models/media_models.dart';
import '../services/content_service.dart';

class AdvancedSearchService {
  final ContentService _contentService;

  AdvancedSearchService(this._contentService);

  /// Busca avançada com múltiplos filtros
  Future<SearchResults> advancedSearch({
    required String query,
    String? category,
    String? year,
    String? genre,
    ContentType? contentType,
  }) async {
    try {
      // Busca básica primeiro
      final basicResults = _contentService.search(query);
      
      List<Channel> filteredChannels = basicResults.channels;
      List<Movie> filteredMovies = basicResults.movies;
      List<Series> filteredSeries = basicResults.series;

      // Filtrar por categoria se especificada
      if (category != null && category.isNotEmpty && category != 'Todos') {
        filteredChannels = filteredChannels
            .where((channel) => channel.category.toLowerCase().contains(category.toLowerCase()))
            .toList();
        filteredMovies = filteredMovies
            .where((movie) => movie.category.toLowerCase().contains(category.toLowerCase()))
            .toList();
        filteredSeries = filteredSeries
            .where((series) => series.category.toLowerCase().contains(category.toLowerCase()))
            .toList();
      }

      // Filtrar por ano se especificado
      if (year != null && year.isNotEmpty) {
        filteredMovies = filteredMovies
            .where((movie) => movie.year?.contains(year) == true)
            .toList();
        filteredSeries = filteredSeries
            .where((series) => series.year?.contains(year) == true)
            .toList();
      }

      // Filtrar por tipo de conteúdo se especificado
      if (contentType != null) {
        switch (contentType) {
          case ContentType.liveTV:
            filteredMovies = [];
            filteredSeries = [];
            break;
          case ContentType.movie:
            filteredChannels = [];
            filteredSeries = [];
            break;
          case ContentType.series:
            filteredChannels = [];
            filteredMovies = [];
            break;
        }
      }

      return SearchResults(
        channels: filteredChannels,
        movies: filteredMovies,
        series: filteredSeries,
        query: query,
      );
    } catch (e) {
      debugPrint('Erro na busca avançada: $e');
      return SearchResults(
        channels: [],
        movies: [],
        series: [],
        query: query,
      );
    }
  }

  /// Busca por gênero/categoria
  List<String> getAvailableGenres() {
    final allCategories = <String>{};
    
    // Adicionar categorias de canais
    for (final channel in _contentService.channels) {
      if (channel.category.isNotEmpty) {
        allCategories.add(channel.category);
      }
    }
    
    // Adicionar categorias de filmes
    for (final movie in _contentService.movies) {
      if (movie.category.isNotEmpty) {
        allCategories.add(movie.category);
      }
    }
    
    // Adicionar categorias de séries
    for (final series in _contentService.series) {
      if (series.category.isNotEmpty) {
        allCategories.add(series.category);
      }
    }
    
    return allCategories.toList()..sort();
  }

  /// Busca por popularidade/rating
  List<Movie> getTopRatedMovies({int limit = 20}) {
    final movies = List<Movie>.from(_contentService.movies);
    movies.sort((a, b) {
      final ratingA = double.tryParse(a.rating ?? '0') ?? 0;
      final ratingB = double.tryParse(b.rating ?? '0') ?? 0;
      return ratingB.compareTo(ratingA);
    });
    
    return movies.take(limit).toList();
  }

  /// Busca por lançamentos recentes
  List<Movie> getRecentMovies({int limit = 20}) {
    final movies = List<Movie>.from(_contentService.movies);
    movies.sort((a, b) {
      final yearA = int.tryParse(a.year ?? '0') ?? 0;
      final yearB = int.tryParse(b.year ?? '0') ?? 0;
      return yearB.compareTo(yearA);
    });
    
    return movies.take(limit).toList();
  }

  /// Busca filmes similares
  List<Movie> getSimilarMovies(Movie movie, {int limit = 10}) {
    return _contentService.movies
        .where((m) => 
            m.id != movie.id && 
            m.category == movie.category)
        .take(limit)
        .toList();
  }

  /// Busca séries similares
  List<Series> getSimilarSeries(Series series, {int limit = 10}) {
    return _contentService.series
        .where((s) => 
            s.id != series.id && 
            s.category == series.category)
        .take(limit)
        .toList();
  }
}

/// Enum para tipos de conteúdo na busca
enum ContentType {
  liveTV,
  movie,
  series,
}
