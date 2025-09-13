import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/media_models.dart';

class CategoryService extends ChangeNotifier {
  List<String> _allChannelCategories = [];
  List<String> _allMovieCategories = [];
  List<String> _allSeriesCategories = [];
  
  String? _selectedChannelCategory;
  String? _selectedMovieCategory;
  String? _selectedSeriesCategory;
  
  Map<String, bool> _hiddenCategories = {};
  List<String> _favoriteCategories = [];
  
  // Getters
  List<String> get allChannelCategories => _allChannelCategories;
  List<String> get allMovieCategories => _allMovieCategories;
  List<String> get allSeriesCategories => _allSeriesCategories;
  
  String? get selectedChannelCategory => _selectedChannelCategory;
  String? get selectedMovieCategory => _selectedMovieCategory;
  String? get selectedSeriesCategory => _selectedSeriesCategory;
  
  List<String> get favoriteCategories => _favoriteCategories;
  
  /// Inicializar serviço
  Future<void> init() async {
    await _loadSettings();
  }
  
  /// Atualizar categorias baseado no conteúdo
  void updateCategories({
    List<Channel>? channels,
    List<Movie>? movies,
    List<Series>? series,
  }) {
    if (channels != null) {
      _allChannelCategories = channels
          .map((c) => c.category)
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      _allChannelCategories.sort();
    }
    
    if (movies != null) {
      _allMovieCategories = movies
          .map((m) => m.category)
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      _allMovieCategories.sort();
    }
    
    if (series != null) {
      _allSeriesCategories = series
          .map((s) => s.category)
          .where((cat) => cat.isNotEmpty)
          .toSet()
          .toList();
      _allSeriesCategories.sort();
    }
    
    notifyListeners();
  }
  
  /// Filtrar canais por categoria
  List<Channel> filterChannels(List<Channel> channels) {
    if (_selectedChannelCategory == null || _selectedChannelCategory == 'Todas') {
      return channels.where((c) => !(_hiddenCategories[c.category] ?? false)).toList();
    }
    
    return channels
        .where((c) => c.category == _selectedChannelCategory)
        .where((c) => !(_hiddenCategories[c.category] ?? false))
        .toList();
  }
  
  /// Filtrar filmes por categoria
  List<Movie> filterMovies(List<Movie> movies) {
    if (_selectedMovieCategory == null || _selectedMovieCategory == 'Todas') {
      return movies.where((m) => !(_hiddenCategories[m.category] ?? false)).toList();
    }
    
    return movies
        .where((m) => m.category == _selectedMovieCategory)
        .where((m) => !(_hiddenCategories[m.category] ?? false))
        .toList();
  }
  
  /// Filtrar séries por categoria
  List<Series> filterSeries(List<Series> series) {
    if (_selectedSeriesCategory == null || _selectedSeriesCategory == 'Todas') {
      return series.where((s) => !(_hiddenCategories[s.category] ?? false)).toList();
    }
    
    return series
        .where((s) => s.category == _selectedSeriesCategory)
        .where((s) => !(_hiddenCategories[s.category] ?? false))
        .toList();
  }
  
  /// Definir categoria selecionada para canais
  void setSelectedChannelCategory(String? category) {
    _selectedChannelCategory = category;
    _saveSettings();
    notifyListeners();
  }
  
  /// Definir categoria selecionada para filmes
  void setSelectedMovieCategory(String? category) {
    _selectedMovieCategory = category;
    _saveSettings();
    notifyListeners();
  }
  
  /// Definir categoria selecionada para séries
  void setSelectedSeriesCategory(String? category) {
    _selectedSeriesCategory = category;
    _saveSettings();
    notifyListeners();
  }
  
  /// Alternar visibilidade de categoria
  void toggleCategoryVisibility(String category) {
    _hiddenCategories[category] = !(_hiddenCategories[category] ?? false);
    _saveSettings();
    notifyListeners();
  }
  
  /// Verificar se categoria está oculta
  bool isCategoryHidden(String category) {
    return _hiddenCategories[category] ?? false;
  }
  
  /// Adicionar/remover categoria dos favoritos
  void toggleFavoriteCategory(String category) {
    if (_favoriteCategories.contains(category)) {
      _favoriteCategories.remove(category);
    } else {
      _favoriteCategories.add(category);
    }
    _saveSettings();
    notifyListeners();
  }
  
  /// Verificar se categoria é favorita
  bool isFavoriteCategory(String category) {
    return _favoriteCategories.contains(category);
  }
  
  /// Obter categorias com contadores
  Map<String, int> getChannelCategoriesWithCount(List<Channel> channels) {
    final Map<String, int> categoryCounts = {};
    
    for (final channel in channels) {
      categoryCounts[channel.category] = (categoryCounts[channel.category] ?? 0) + 1;
    }
    
    return categoryCounts;
  }
  
  /// Obter categorias de filmes com contadores
  Map<String, int> getMovieCategoriesWithCount(List<Movie> movies) {
    final Map<String, int> categoryCounts = {};
    
    for (final movie in movies) {
      categoryCounts[movie.category] = (categoryCounts[movie.category] ?? 0) + 1;
    }
    
    return categoryCounts;
  }
  
  /// Obter categorias de séries com contadores
  Map<String, int> getSeriesCategoriesWithCount(List<Series> series) {
    final Map<String, int> categoryCounts = {};
    
    for (final serie in series) {
      categoryCounts[serie.category] = (categoryCounts[serie.category] ?? 0) + 1;
    }
    
    return categoryCounts;
  }
  
  /// Limpar todas as seleções
  void clearAllSelections() {
    _selectedChannelCategory = null;
    _selectedMovieCategory = null;
    _selectedSeriesCategory = null;
    _saveSettings();
    notifyListeners();
  }
  
  /// Resetar configurações
  void resetSettings() {
    _selectedChannelCategory = null;
    _selectedMovieCategory = null;
    _selectedSeriesCategory = null;
    _hiddenCategories.clear();
    _favoriteCategories.clear();
    _saveSettings();
    notifyListeners();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _selectedChannelCategory = prefs.getString('selected_channel_category');
      _selectedMovieCategory = prefs.getString('selected_movie_category');
      _selectedSeriesCategory = prefs.getString('selected_series_category');
      
      final hiddenJson = prefs.getString('hidden_categories');
      if (hiddenJson != null) {
        final Map<String, dynamic> hidden = json.decode(hiddenJson);
        _hiddenCategories = hidden.map((k, v) => MapEntry(k, v as bool));
      }
      
      final favoritesJson = prefs.getString('favorite_categories');
      if (favoritesJson != null) {
        _favoriteCategories = List<String>.from(json.decode(favoritesJson));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configurações de categoria: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_selectedChannelCategory != null) {
        await prefs.setString('selected_channel_category', _selectedChannelCategory!);
      } else {
        await prefs.remove('selected_channel_category');
      }
      
      if (_selectedMovieCategory != null) {
        await prefs.setString('selected_movie_category', _selectedMovieCategory!);
      } else {
        await prefs.remove('selected_movie_category');
      }
      
      if (_selectedSeriesCategory != null) {
        await prefs.setString('selected_series_category', _selectedSeriesCategory!);
      } else {
        await prefs.remove('selected_series_category');
      }
      
      await prefs.setString('hidden_categories', json.encode(_hiddenCategories));
      await prefs.setString('favorite_categories', json.encode(_favoriteCategories));
    } catch (e) {
      debugPrint('Erro ao salvar configurações de categoria: $e');
    }
  }
}
