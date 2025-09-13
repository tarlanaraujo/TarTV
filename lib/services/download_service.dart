import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../models/media_models.dart';
import 'auth_service.dart';

class DownloadService extends ChangeNotifier {
  final List<DownloadItem> _downloads = [];
  final List<DownloadItem> _downloadHistory = [];
  bool _autoDownloadFavorites = false;
  
  AuthService? _authService;
  
  List<DownloadItem> get downloads => List.unmodifiable(_downloads);
  List<DownloadItem> get downloadHistory => List.unmodifiable(_downloadHistory);
  bool get autoDownloadFavorites => _autoDownloadFavorites;
  
  // Método de debug
  void debugPrintState() {
    debugPrint('🔍 DownloadService Debug State:');
    debugPrint('  - Downloads ativos: ${_downloads.length}');
    debugPrint('  - Histórico: ${_downloadHistory.length}');
    for (int i = 0; i < _downloads.length; i++) {
      final item = _downloads[i];
      debugPrint('    ${i+1}. ${item.title} - ${item.status} - ${(item.progress * 100).toStringAsFixed(1)}%');
    }
  }
  
  // Definir o AuthService
  void setAuthService(AuthService authService) {
    _authService = authService;
  }
  
  // Inicializar o serviço
  Future<void> init() async {
    await loadDownloadHistory();
    await _loadDownloads(); // Carregar downloads em progresso
    await _loadAutoDownloadSetting();
  }
  
  // Configuração de download automático
  Future<void> _loadAutoDownloadSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoDownloadFavorites = prefs.getBool('auto_download_favorites') ?? false;
    } catch (e) {
      debugPrint('Erro ao carregar configuração de auto download: $e');
    }
  }
  
  Future<void> setAutoDownloadFavorites(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_download_favorites', value);
      _autoDownloadFavorites = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar configuração de auto download: $e');
    }
  }
  
  Future<bool> requestStoragePermission() async {
    try {
      // No Flutter Web, não precisamos de permissões de armazenamento
      if (kIsWeb) {
        return true;
      }
      
      // Para iOS, permissões são tratadas automaticamente pelo sistema
      if (Platform.isIOS) {
        debugPrint('📱 iOS - Permissões gerenciadas automaticamente');
        return true;
      }
      
      // Para Android, solicitar permissões múltiplas
      if (Platform.isAndroid) {
        debugPrint('🔐 Verificando permissões de armazenamento...');
        
        // Verificar se já temos alguma permissão
        bool hasPermission = await Permission.photos.isGranted || 
                           await Permission.videos.isGranted ||
                           await Permission.storage.isGranted;
        
        if (hasPermission) {
          debugPrint('✅ Permissões já concedidas');
          return true;
        }
        
        // Solicitar permissões uma por vez
        debugPrint('📱 Solicitando permissão de fotos/mídia...');
        var photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          debugPrint('✅ Permissão de fotos concedida');
          return true;
        }
        
        debugPrint('📱 Solicitando permissão de vídeos...');
        var videosStatus = await Permission.videos.request();
        if (videosStatus.isGranted) {
          debugPrint('✅ Permissão de vídeos concedida');
          return true;
        }
        
        debugPrint('📱 Solicitando permissão de armazenamento...');
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          debugPrint('✅ Permissão de armazenamento concedida');
          return true;
        }
        
        // Se negadas permanentemente, abrir configurações
        if (photosStatus.isPermanentlyDenied || 
            videosStatus.isPermanentlyDenied || 
            storageStatus.isPermanentlyDenied) {
          debugPrint('⚙️ Permissões negadas permanentemente - abrindo configurações');
          await openAppSettings();
          return false;
        }
        
        debugPrint('❌ Permissões negadas pelo usuário');
        return false;
      }
      
      // Para outras plataformas, assumir que não precisamos de permissão
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao solicitar permissão: $e');
      return false;
    }
  }
  
  Future<String> getDownloadPath() async {
    try {
      // No Flutter Web, usar um caminho temporário ou simulado
      if (kIsWeb) {
        return '/downloads'; // Caminho simulado para web
      }
      
      if (Platform.isIOS) {
        // iOS: Usar Documents directory (App Sandbox)
        final directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${directory.path}/TarTV/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        debugPrint('📁 iOS Download path: ${downloadDir.path}');
        return downloadDir.path;
      } else {
        // Android: Usar storage externo
        final directory = await getExternalStorageDirectory();
        final downloadDir = Directory('${directory!.path}/TarTV/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        debugPrint('📁 Android Download path: ${downloadDir.path}');
        return downloadDir.path;
      }
    } catch (e) {
      debugPrint('❌ Erro ao obter caminho de download: $e');
      return '/downloads'; // Fallback
    }
  }
  
  Future<void> downloadMovie(Movie movie, String quality) async {
    debugPrint('🎬 downloadMovie chamado para: ${movie.name}');
    debugPrint('🆔 Movie ID: ${movie.id}');
    debugPrint('🔗 Movie URL original: ${movie.url}');
    
    if (!await requestStoragePermission()) {
      throw Exception('Permissão de armazenamento negada');
    }
    
    final downloadUrl = _getMovieDownloadUrl(movie, quality);
    debugPrint('🔗 URL final para download: $downloadUrl');
    
    final downloadItem = DownloadItem(
      id: movie.streamId.toString(),
      title: movie.name,
      type: DownloadType.movie,
      quality: quality,
      progress: 0.0,
      status: DownloadStatus.downloading,
      url: downloadUrl,
    );
    
    debugPrint('🔽 Adicionando à lista de downloads: ${movie.name}');
    debugPrint('� Downloads atuais: ${_downloads.length}');
    
    _downloads.add(downloadItem);
    debugPrint('📋 Downloads após adicionar: ${_downloads.length}');
    debugPrintState(); // Debug do estado completo
    
    // Forçar notificação com pequeno delay
    notifyListeners();
    debugPrint('🔔 notifyListeners() chamado após adicionar download');
    
    // Segundo notifyListeners após delay para garantir que a UI seja atualizada
    Future.delayed(const Duration(milliseconds: 100), () {
      notifyListeners();
      debugPrint('🔔 notifyListeners() chamado após delay');
    });
    
    try {
      await _startDownload(downloadItem);
    } catch (e) {
      debugPrint('❌ Erro no download: $e');
      downloadItem.status = DownloadStatus.failed;
      downloadItem.error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> downloadSeries(Series series, Season season, Episode episode, String quality) async {
    if (!await requestStoragePermission()) {
      throw Exception('Permissão de armazenamento negada');
    }
    
    final downloadItem = DownloadItem(
      id: '${series.seriesId}_${season.seasonNumber}_${episode.id}',
      title: '${series.name} - T${season.seasonNumber}E${episode.episodeNumber} - ${episode.name}',
      type: DownloadType.episode,
      quality: quality,
      progress: 0.0,
      status: DownloadStatus.downloading,
      url: _getEpisodeDownloadUrl(series, episode, quality),
    );
    
    _downloads.add(downloadItem);
    await _saveDownloads(); // Salvar imediatamente
    notifyListeners();
    
    debugPrint('✅ Download adicionado à lista: ${downloadItem.title}');
    
    try {
      await _startDownload(downloadItem);
    } catch (e) {
      debugPrint('❌ Erro no download: $e');
      downloadItem.status = DownloadStatus.failed;
      downloadItem.error = e.toString();
      await _saveDownloads();
      notifyListeners();
    }
  }
  
  String _getMovieDownloadUrl(Movie movie, String quality) {
    // Se já temos uma URL completa, usamos ela
    if (movie.url.startsWith('http')) {
      return movie.url;
    }
    
    // Se temos AuthService configurado, construir URL Xtream
    if (_authService?.serverUrl != null && _authService?.username != null) {
      final server = _authService!.serverUrl!;
      final username = _authService!.username!;
      final password = _authService?.password ?? '';
      
      // Construir URL de download Xtream (usar streamId que é o alias para id)
      return '$server/movie/$username/$password/${movie.streamId}.mp4';
    }
    
    // Fallback para URL original
    return movie.url;
  }
  
  String _getEpisodeDownloadUrl(Series series, Episode episode, String quality) {
    // Se já temos uma URL completa, usamos ela
    if (episode.url.startsWith('http')) {
      return episode.url;
    }
    
    // Se temos AuthService configurado, construir URL Xtream
    if (_authService?.serverUrl != null && _authService?.username != null) {
      final server = _authService!.serverUrl!;
      final username = _authService!.username!;
      final password = _authService?.password ?? '';
      
      // Construir URL de download Xtream para série
      return '$server/series/$username/$password/${episode.id}.mp4';
    }
    
    // Fallback para URL original
    return episode.url;
  }
  
  Future<void> _startDownload(DownloadItem item) async {
    try {
      debugPrint('� === INICIANDO DOWNLOAD ===');
      debugPrint('�📁 Preparando download: ${item.title}');
      debugPrint('🔗 URL original: ${item.url}');
      
      final downloadPath = await getDownloadPath();
      final fileName = '${item.title.replaceAll(RegExp(r'[^\w\s-]'), '')}.mp4'; // Sempre MP4 para simplicidade
      final filePath = '$downloadPath/$fileName';
      debugPrint('📍 Caminho final: $filePath');
      
      // Testar conectividade da URL
      debugPrint('🌐 Testando conectividade da URL...');
      
      try {
        final headResponse = await http.head(Uri.parse(item.url)).timeout(
          const Duration(seconds: 10),
        );
        debugPrint('📡 HEAD Status: ${headResponse.statusCode}');
        debugPrint('📊 Content-Length: ${headResponse.headers['content-length']}');
        
        if (headResponse.statusCode != 200) {
          throw Exception('URL não acessível (Status: ${headResponse.statusCode})');
        }
      } catch (e) {
        debugPrint('⚠️ HEAD request falhou, tentando GET direto: $e');
      }
      
      
      debugPrint('🌐 Fazendo download real...');
      
      // Usar streaming para download com progresso real
      final request = http.Request('GET', Uri.parse(item.url));
      request.headers['User-Agent'] = 'TarTV/1.0'; // Alguns servidores precisam disso
      
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 30), // Timeout de 30 minutos
      );
      
      debugPrint('📡 Stream Status: ${streamedResponse.statusCode}');
      
      if (streamedResponse.statusCode == 200) {
        final contentLength = streamedResponse.contentLength ?? 0;
        debugPrint('📊 Tamanho do conteúdo: $contentLength bytes (${(contentLength / (1024 * 1024)).toStringAsFixed(2)} MB)');
        
        if (!kIsWeb) {
          final file = File(filePath);
          final sink = file.openWrite();
          
          int bytesReceived = 0;
          final stopwatch = Stopwatch()..start();
          
          await for (final chunk in streamedResponse.stream) {
            sink.add(chunk);
            bytesReceived += chunk.length;
            
            // Atualizar progresso
            if (contentLength > 0) {
              final newProgress = bytesReceived / contentLength;
              if ((newProgress - item.progress).abs() > 0.01) { // Só notificar a cada 1%
                item.progress = newProgress;
                final elapsed = stopwatch.elapsedMilliseconds;
                final speed = elapsed > 0 ? (bytesReceived / elapsed) * 1000 : 0; // bytes/s
                debugPrint('📈 Progresso: ${(newProgress * 100).toStringAsFixed(1)}% - ${(bytesReceived / (1024 * 1024)).toStringAsFixed(2)}MB de ${(contentLength / (1024 * 1024)).toStringAsFixed(2)}MB - ${(speed / 1024).toStringAsFixed(1)} KB/s');
                notifyListeners();
              }
            } else {
              // Sem content-length, mostrar apenas bytes baixados
              if (bytesReceived % (1024 * 1024) == 0) { // A cada MB
                debugPrint('📥 Baixado: ${(bytesReceived / (1024 * 1024)).toStringAsFixed(2)} MB');
              }
            }
          }
          
          await sink.flush();
          await sink.close();
          
          if (contentLength == 0 || bytesReceived == contentLength) {
            item.progress = 1.0;
          }
          
          // Verificar se arquivo foi criado corretamente
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint('✅ Arquivo criado: $filePath (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB)');
          } else {
            throw Exception('Arquivo não foi criado');
          }
        } else {
          // Para Flutter Web, simular download
          debugPrint('🌐 Simulando download no web...');
          item.progress = 1.0;
        }
        
        debugPrint('✅ Download concluído!');
        item.status = DownloadStatus.completed;
        item.downloadedAt = DateTime.now();
        item.localPath = filePath;
        
        // Verificar se arquivo foi salvo corretamente
        if (!kIsWeb && filePath.isNotEmpty) {
          final file = File(filePath);
          if (await file.exists()) {
            final fileSize = await file.length();
            debugPrint('📁 Arquivo salvo: $filePath (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB)');
            debugPrint('🔗 Path para player: file://$filePath');
          } else {
            debugPrint('❌ ERRO: Arquivo não encontrado após download: $filePath');
          }
        }
        
        _downloadHistory.add(item);
        _downloads.remove(item);
        
        await _saveDownloads(); // Salvar estado atual
        await _saveDownloadHistory();
        debugPrint('💾 Histórico salvo');
        notifyListeners();
        debugPrint('🔔 Listeners notificados - Download ID: ${item.id}');
        debugPrintState(); // Debug do estado atual
      } else {
        throw Exception('Falha no download: Status ${streamedResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro no _startDownload: $e');
      item.status = DownloadStatus.failed;
      item.error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> _saveDownloadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = _downloadHistory.map((item) => {
        'id': item.id,
        'title': item.title,
        'type': item.type.toString(),
        'quality': item.quality,
        'url': item.url,
        'localPath': item.localPath,
        'downloadedAt': item.downloadedAt?.toIso8601String(),
      }).toList();
      
      await prefs.setString('download_history', json.encode(history));
    } catch (e) {
      debugPrint('Erro ao salvar histórico de downloads: $e');
    }
  }
  
  Future<void> loadDownloadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('download_history');
      
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        
        _downloadHistory.clear();
        for (final item in historyList) {
          final downloadItem = DownloadItem(
            id: item['id'],
            title: item['title'],
            type: DownloadType.values.firstWhere((e) => e.toString() == item['type']),
            quality: item['quality'],
            url: item['url'],
            status: DownloadStatus.completed,
            progress: 1.0,
            localPath: item['localPath'],
            downloadedAt: item['downloadedAt'] != null 
                ? DateTime.parse(item['downloadedAt'])
                : null,
          );
          
          // Verificar se o arquivo ainda existe
          if (downloadItem.localPath != null && 
              await File(downloadItem.localPath!).exists()) {
            _downloadHistory.add(downloadItem);
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar histórico de downloads: $e');
    }
  }
  
  void cancelDownload(String id) {
    final item = _downloads.firstWhere((d) => d.id == id);
    item.status = DownloadStatus.cancelled;
    _downloads.remove(item);
    notifyListeners();
  }
  
  void pauseDownload(String id) {
    final item = _downloads.firstWhere((d) => d.id == id);
    item.status = DownloadStatus.paused;
    notifyListeners();
  }
  
  void resumeDownload(String id) {
    final item = _downloads.firstWhere((d) => d.id == id);
    item.status = DownloadStatus.downloading;
    notifyListeners();
  }
  
  void removeFromHistory(String id) {
    _downloadHistory.removeWhere((d) => d.id == id);
    notifyListeners();
  }
  
  void clearHistory() {
    _downloadHistory.clear();
    _saveDownloadHistory();
    notifyListeners();
  }
  
  // Método para salvar downloads em progresso
  Future<void> _saveDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadData = _downloads.map((item) => {
        'id': item.id,
        'title': item.title,
        'type': item.type.toString(),
        'quality': item.quality,
        'url': item.url,
        'progress': item.progress,
        'status': item.status.toString(),
        'error': item.error,
        'localPath': item.localPath,
      }).toList();
      
      await prefs.setString('current_downloads', jsonEncode(downloadData));
    } catch (e) {
      debugPrint('Erro ao salvar downloads: $e');
    }
  }
  
  // Método para carregar downloads em progresso
  Future<void> _loadDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = prefs.getString('current_downloads');
      
      if (downloadsJson != null) {
        final List<dynamic> downloadList = jsonDecode(downloadsJson);
        
        _downloads.clear();
        for (final item in downloadList) {
          final downloadItem = DownloadItem(
            id: item['id'],
            title: item['title'],
            type: DownloadType.values.firstWhere((e) => e.toString() == item['type']),
            quality: item['quality'],
            url: item['url'],
            progress: item['progress'] ?? 0.0,
            status: DownloadStatus.values.firstWhere((e) => e.toString() == item['status']),
            error: item['error'],
            localPath: item['localPath'],
          );
          
          _downloads.add(downloadItem);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar downloads: $e');
    }
  }
  
  /// Download automático de todos os favoritos
  void downloadAllFavorites() {
    // Esta função será chamada com acesso aos favoritos via Provider
    // A implementação real será feita no contexto da UI
    debugPrint('🔄 Iniciando download automático de favoritos...');
    // Implementação será feita via context no settings_screen
  }
}

class DownloadItem {
  final String id;
  final String title;
  final DownloadType type;
  final String quality;
  final String url;
  
  double progress;
  DownloadStatus status;
  DateTime? downloadedAt;
  String? error;
  String? localPath;
  
  DownloadItem({
    required this.id,
    required this.title,
    required this.type,
    required this.quality,
    required this.url,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.downloadedAt,
    this.error,
    this.localPath,
  });
}

enum DownloadType { movie, episode }

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}
