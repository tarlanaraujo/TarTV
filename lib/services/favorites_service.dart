import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/media_models.dart';

class FavoritesService extends ChangeNotifier {
  List<Channel> _favoriteChannels = [];
  List<Movie> _favoriteMovies = [];
  List<Series> _favoriteSeries = [];
  
  // Getters
  List<Channel> get favoriteChannels => _favoriteChannels;
  List<Movie> get favoriteMovies => _favoriteMovies;
  List<Series> get favoriteSeries => _favoriteSeries;
  
  int get totalFavorites => 
    _favoriteChannels.length + 
    _favoriteMovies.length + 
    _favoriteSeries.length;
  
  // Inicializar serviço
  Future<void> init() async {
    await _loadFavorites();
  }
  
  // Carregar favoritos do storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carregar canais favoritos
      final channelsJson = prefs.getString('favorite_channels');
      if (channelsJson != null) {
        final channelsList = json.decode(channelsJson) as List;
        _favoriteChannels = channelsList.map((c) => Channel.fromJson(c)).toList();
      }
      
      // Carregar filmes favoritos
      final moviesJson = prefs.getString('favorite_movies');
      if (moviesJson != null) {
        final moviesList = json.decode(moviesJson) as List;
        _favoriteMovies = moviesList.map((m) => Movie.fromJson(m)).toList();
      }
      
      // Carregar séries favoritas
      final seriesJson = prefs.getString('favorite_series');
      if (seriesJson != null) {
        final seriesList = json.decode(seriesJson) as List;
        _favoriteSeries = seriesList.map((s) => Series.fromJson(s)).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
    }
  }
  
  // Salvar favoritos no storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('favorite_channels', json.encode(_favoriteChannels.map((c) => c.toJson()).toList()));
      await prefs.setString('favorite_movies', json.encode(_favoriteMovies.map((m) => m.toJson()).toList()));
      await prefs.setString('favorite_series', json.encode(_favoriteSeries.map((s) => s.toJson()).toList()));
      
    } catch (e) {
      debugPrint('Erro ao salvar favoritos: $e');
    }
  }
  
  // ===== CANAIS =====
  bool isChannelFavorite(Channel channel) {
    return _favoriteChannels.any((c) => c.id == channel.id);
  }
  
  Future<void> toggleChannelFavorite(Channel channel) async {
    if (isChannelFavorite(channel)) {
      _favoriteChannels.removeWhere((c) => c.id == channel.id);
    } else {
      _favoriteChannels.add(channel);
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  // ===== FILMES =====
  bool isMovieFavorite(Movie movie) {
    return _favoriteMovies.any((m) => m.id == movie.id);
  }
  
  Future<void> toggleMovieFavorite(Movie movie) async {
    if (isMovieFavorite(movie)) {
      _favoriteMovies.removeWhere((m) => m.id == movie.id);
    } else {
      _favoriteMovies.add(movie);
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  // ===== SÉRIES =====
  bool isSeriesFavorite(Series series) {
    return _favoriteSeries.any((s) => s.id == series.id);
  }
  
  Future<void> toggleSeriesFavorite(Series series) async {
    if (isSeriesFavorite(series)) {
      _favoriteSeries.removeWhere((s) => s.id == series.id);
    } else {
      _favoriteSeries.add(series);
    }
    await _saveFavorites();
    notifyListeners();
  }
  
  // ===== UTILITÁRIOS =====
  Future<void> clearAllFavorites() async {
    _favoriteChannels.clear();
    _favoriteMovies.clear();
    _favoriteSeries.clear();
    await _saveFavorites();
    notifyListeners();
  }
  
  // Buscar nos favoritos
  List<dynamic> searchFavorites(String query) {
    final lowerQuery = query.toLowerCase();
    final List<dynamic> results = [];
    
    // Buscar canais
    results.addAll(_favoriteChannels.where((channel) => 
      channel.name.toLowerCase().contains(lowerQuery)));
    
    // Buscar filmes
    results.addAll(_favoriteMovies.where((movie) => 
      movie.name.toLowerCase().contains(lowerQuery)));
    
    // Buscar séries
    results.addAll(_favoriteSeries.where((series) => 
      series.name.toLowerCase().contains(lowerQuery)));
    
    return results;
  }
}
