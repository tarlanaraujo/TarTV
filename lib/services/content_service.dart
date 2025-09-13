import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/media_models.dart';
import 'xtream_service.dart';
import 'm3u_service.dart';
import 'm3u_parser_service.dart';
import 'auth_service.dart';

class ContentService extends ChangeNotifier {
  XtreamService? _xtreamService;
  M3UService? _m3uService;
  AuthService? _authService;
  M3UPlaylist? _currentPlaylist;
  
  // Cache dos dados
  List<Channel> _channels = [];
  List<Movie> _movies = [];
  List<Series> _series = [];
  List<String> _categories = [];
  
  // Estados de carregamento
  bool _isLoadingChannels = false;
  bool _isLoadingMovies = false;
  bool _isLoadingSeries = false;
  String? _errorMessage;
  
  // Getters
  List<Channel> get channels => _channels;
  List<Movie> get movies => _movies;
  List<Series> get series => _series;
  List<String> get categories => _categories;
  bool get isLoadingChannels => _isLoadingChannels;
  bool get isLoadingMovies => _isLoadingMovies;
  bool get isLoadingSeries => _isLoadingSeries;
  String? get errorMessage => _errorMessage;
  bool get hasData => _channels.isNotEmpty || _movies.isNotEmpty || _series.isNotEmpty;
  
  // Inicializar com cache
  Future<void> init() async {
    await _loadFromCache();
  }
  
  /// Inicializa o serviço com credenciais Xtream
  void initializeXtream(String serverUrl, String username, String password) {
    _xtreamService = XtreamService(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
    _m3uService = null;
    _currentPlaylist = null;
    _clearData();
  }
  
  /// Inicializa o serviço com M3U
  void initializeM3U() {
    _m3uService = M3UService();
    _xtreamService = null;
    _clearData();
    
    // Se temos AuthService com conteúdo M3U, carregar automaticamente
    if (_authService != null) {
      if (_authService!.authMethod == AuthMethod.m3uFile && _authService!.m3uContent != null) {
        _loadM3UContent(_authService!.m3uContent!);
      } else if (_authService!.authMethod == AuthMethod.m3uUrl && _authService!.serverUrl != null) {
        loadM3UFromUrl(_authService!.serverUrl!);
      }
    }
  }
  
  /// Define o AuthService para acesso aos dados de autenticação
  void setAuthService(AuthService authService) {
    _authService = authService;
  }
  
  /// Carrega playlist M3U de uma URL
  Future<void> loadM3UFromUrl(String url) async {
    if (_m3uService == null) {
      throw Exception('Serviço M3U não inicializado');
    }
    
    try {
      _setLoading(true);
      _currentPlaylist = await _m3uService!.loadFromUrl(url);
      _updateDataFromPlaylist();
      _errorMessage = null;
      await _saveToCache(); // Salvar dados no cache após carregamento
    } catch (e) {
      _errorMessage = e.toString();
      _clearData();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Carrega playlist M3U de um arquivo
  Future<void> loadM3UFromFile(String filePath) async {
    try {
      _setLoading(true);
      
      // Se temos um AuthService com conteúdo M3U, usar ele
      if (_authService != null && _authService!.authMethod == AuthMethod.m3uFile) {
        final m3uContent = _authService!.m3uContent;
        if (m3uContent != null) {
          _loadM3UContent(m3uContent);
          return;
        }
      }
      
      // Fallback para M3UService se disponível
      if (_m3uService != null) {
        _currentPlaylist = await _m3uService!.loadFromFile(filePath);
        _updateDataFromPlaylist();
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _clearData();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Carrega canais ao vivo via Xtream
  Future<void> loadLiveChannels({String? categoryId}) async {
    if (_xtreamService == null) {
      throw Exception('Serviço Xtream não inicializado');
    }
    
    try {
      _isLoadingChannels = true;
      notifyListeners();
      
      _channels = await _xtreamService!.getLiveChannels(categoryId: categoryId);
      
      // Salvar no cache automaticamente
      await _saveToCache();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _channels = [];
    } finally {
      _isLoadingChannels = false;
      notifyListeners();
    }
  }
  
  /// Carrega filmes via Xtream
  Future<void> loadMovies({String? categoryId}) async {
    if (_xtreamService == null) {
      throw Exception('Serviço Xtream não inicializado');
    }
    
    try {
      _isLoadingMovies = true;
      notifyListeners();
      
      _movies = await _xtreamService!.getMovies(categoryId: categoryId);
      
      // Salvar no cache automaticamente
      await _saveToCache();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _movies = [];
    } finally {
      _isLoadingMovies = false;
      notifyListeners();
    }
  }
  
  /// Carrega séries via Xtream
  Future<void> loadSeries({String? categoryId}) async {
    if (_xtreamService == null) {
      throw Exception('Serviço Xtream não inicializado');
    }
    
    try {
      _isLoadingSeries = true;
      notifyListeners();
      
      _series = await _xtreamService!.getSeries(categoryId: categoryId);
      
      // Salvar no cache automaticamente  
      await _saveToCache();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _series = [];
    } finally {
      _isLoadingSeries = false;
      notifyListeners();
    }
  }
  
  /// Carrega categorias de canais ao vivo
  Future<List<dynamic>> getLiveTVCategories() async {
    if (_xtreamService == null) return [];
    try {
      return await _xtreamService!.getLiveTVCategories();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
  
  /// Carrega categorias de filmes
  Future<List<dynamic>> getMovieCategories() async {
    if (_xtreamService == null) return [];
    try {
      return await _xtreamService!.getMovieCategories();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
  
  /// Carrega categorias de séries
  Future<List<dynamic>> getSeriesCategories() async {
    if (_xtreamService == null) return [];
    try {
      return await _xtreamService!.getSeriesCategories();
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
  
  /// Obtém informações detalhadas de uma série
  Future<Series?> getSeriesInfo(String seriesId) async {
    if (_xtreamService == null) return null;
    try {
      return await _xtreamService!.getSeriesInfo(seriesId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }
  
  /// Filtra canais por categoria
  List<Channel> getChannelsByCategory(String category) {
    if (category == 'Todos') return _channels;
    return _channels.where((channel) => channel.category == category).toList();
  }
  
  /// Filtra filmes por categoria
  List<Movie> getMoviesByCategory(String category) {
    if (category == 'Todos') return _movies;
    return _movies.where((movie) => movie.category == category).toList();
  }
  
  /// Filtra séries por categoria
  List<Series> getSeriesByCategory(String category) {
    if (category == 'Todos') return _series;
    return _series.where((series) => series.category == category).toList();
  }
  
  /// Busca por nome em todos os tipos de conteúdo
  SearchResults search(String query) {
    final lowerQuery = query.toLowerCase();
    
    final foundChannels = _channels
        .where((channel) => channel.name.toLowerCase().contains(lowerQuery))
        .toList();
    
    final foundMovies = _movies
        .where((movie) => movie.name.toLowerCase().contains(lowerQuery))
        .toList();
    
    final foundSeries = _series
        .where((series) => series.name.toLowerCase().contains(lowerQuery))
        .toList();
    
    return SearchResults(
      channels: foundChannels,
      movies: foundMovies,
      series: foundSeries,
      query: query,
    );
  }
  
  /// Testa a conectividade com o servidor
  Future<bool> testConnection() async {
    if (_xtreamService == null) return false;
    
    try {
      final serverInfo = await _xtreamService!.getServerInfo();
      return serverInfo != null && serverInfo.isNotEmpty;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  /// Atualiza dados da playlist M3U
  void _updateDataFromPlaylist() {
    if (_currentPlaylist == null) return;
    
    _channels = _currentPlaylist!.channels;
    _movies = _currentPlaylist!.movies;
    _series = _currentPlaylist!.series;
    _categories = ['Todos', ..._currentPlaylist!.categories];
    
    notifyListeners();
  }
  
  /// Define estados de carregamento
  void _setLoading(bool loading) {
    _isLoadingChannels = loading;
    _isLoadingMovies = loading;
    _isLoadingSeries = loading;
    notifyListeners();
  }
  
  /// Limpa todos os dados
  void _clearData() {
    _channels = [];
    _movies = [];
    _series = [];
    _categories = [];
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Limpa dados e cache ao trocar de conta
  void clearDataForAccountSwitch() {
    debugPrint('ContentService: Limpando dados para troca de conta');
    _clearData();
    // Não limpar o cache aqui, ele deve ser isolado por conta
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Métodos de cache para persistir dados após reiniciar app
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Usar cache específico para cada conta
      final accountKey = _getAccountCacheKey();
      if (accountKey == null) {
        debugPrint('ContentService: Nenhuma conta ativa para carregar cache');
        return;
      }
      
      final channelsJson = prefs.getString('cached_channels_$accountKey');
      final moviesJson = prefs.getString('cached_movies_$accountKey');
      final seriesJson = prefs.getString('cached_series_$accountKey');
      
      if (channelsJson != null) {
        final List<dynamic> channelsList = json.decode(channelsJson);
        _channels = channelsList.map((json) => Channel.fromJson(json)).toList();
        debugPrint('ContentService: ${_channels.length} canais carregados do cache da conta $accountKey');
      }
      
      if (moviesJson != null) {
        final List<dynamic> moviesList = json.decode(moviesJson);
        _movies = moviesList.map((json) => Movie.fromJson(json)).toList();
        debugPrint('ContentService: ${_movies.length} filmes carregados do cache da conta $accountKey');
      }
      
      if (seriesJson != null) {
        final List<dynamic> seriesList = json.decode(seriesJson);
        _series = seriesList.map((json) => Series.fromJson(json)).toList();
        debugPrint('ContentService: ${_series.length} séries carregadas do cache da conta $accountKey');
      }
      
      if (_channels.isNotEmpty || _movies.isNotEmpty || _series.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar cache: $e');
    }
  }
  
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Usar cache específico para cada conta
      final accountKey = _getAccountCacheKey();
      if (accountKey == null) {
        debugPrint('ContentService: Nenhuma conta ativa para salvar cache');
        return;
      }
      
      if (_channels.isNotEmpty) {
        final channelsJson = json.encode(_channels.map((c) => c.toJson()).toList());
        await prefs.setString('cached_channels_$accountKey', channelsJson);
        debugPrint('ContentService: Cache de canais salvo para conta $accountKey');
      }
      
      if (_movies.isNotEmpty) {
        final moviesJson = json.encode(_movies.map((m) => m.toJson()).toList());
        await prefs.setString('cached_movies_$accountKey', moviesJson);
        debugPrint('ContentService: Cache de filmes salvo para conta $accountKey');
      }
      
      if (_series.isNotEmpty) {
        final seriesJson = json.encode(_series.map((s) => s.toJson()).toList());
        await prefs.setString('cached_series_$accountKey', seriesJson);
        debugPrint('ContentService: Cache de séries salvo para conta $accountKey');
      }
    } catch (e) {
      debugPrint('Erro ao salvar cache: $e');
    }
  }
  
  /// Gera uma chave única para o cache baseada na conta atual
  String? _getAccountCacheKey() {
    if (_authService == null || !_authService!.isAuthenticated) {
      return null;
    }
    
    // Criar chave única baseada no método de autenticação e dados da conta
    switch (_authService!.authMethod) {
      case AuthMethod.xtream:
        final server = _authService!.serverUrl ?? '';
        final username = _authService!.username ?? '';
        return '${server}_$username'.replaceAll(RegExp(r'[^\w]'), '_');
      
      case AuthMethod.m3uUrl:
        final url = _authService!.serverUrl ?? '';
        return 'm3u_url_${url.hashCode}';
      
      case AuthMethod.m3uFile:
        final filePath = _authService!.serverUrl ?? '';
        return 'm3u_file_${filePath.hashCode}';
    }
  }
  
  /// Carrega conteúdo M3U a partir de string
  void _loadM3UContent(String m3uContent) {
    try {
      if (!M3UParserService.isValidM3U(m3uContent)) {
        throw Exception('Conteúdo M3U inválido');
      }
      
      // O parser já retorna Channel no formato correto
      _channels = M3UParserService.parseM3UContent(m3uContent);
      
      // Extrair categorias únicas
      final categoriesSet = <String>{};
      for (final channel in _channels) {
        categoriesSet.add(channel.category);
      }
      _categories = categoriesSet.toList()..sort();
      
      // Salvar no cache
      _saveToCache();
      
      debugPrint('ContentService: ${_channels.length} canais carregados do M3U');
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao processar conteúdo M3U: $e');
      rethrow;
    }
  }
}

/// Classe para resultados de busca
class SearchResults {
  final List<Channel> channels;
  final List<Movie> movies;
  final List<Series> series;
  final String query;
  
  SearchResults({
    required this.channels,
    required this.movies,
    required this.series,
    required this.query,
  });
  
  int get totalResults => channels.length + movies.length + series.length;
  bool get hasResults => totalResults > 0;
}
