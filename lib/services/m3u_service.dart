import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/media_models.dart';

class M3UService {
  static const int _receiveTimeout = 30;

  /// Carrega e processa uma playlist M3U de uma URL
  Future<M3UPlaylist> loadFromUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TarTV/1.0',
          'Accept': '*/*',
        },
      ).timeout(const Duration(seconds: _receiveTimeout));

      if (response.statusCode == 200) {
        final content = _detectEncoding(response.bodyBytes);
        return _parseM3UContent(content, url);
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar playlist: $e');
    }
  }

  /// Carrega e processa uma playlist M3U de um arquivo
  Future<M3UPlaylist> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado: $filePath');
      }

      final bytes = await file.readAsBytes();
      final content = _detectEncoding(bytes);
      return _parseM3UContent(content, filePath);
    } catch (e) {
      throw Exception('Erro ao carregar arquivo: $e');
    }
  }

  /// Detecta a codificação do arquivo e converte para String
  String _detectEncoding(List<int> bytes) {
    try {
      // Tenta UTF-8 primeiro
      return utf8.decode(bytes);
    } catch (e) {
      try {
        // Fallback para Latin-1
        return latin1.decode(bytes);
      } catch (e) {
        // Último recurso - força UTF-8 ignorando erros
        return utf8.decode(bytes, allowMalformed: true);
      }
    }
  }

  /// Processa o conteúdo M3U e categoriza o conteúdo
  M3UPlaylist _parseM3UContent(String content, String source) {
    final lines = content.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    
    if (lines.isEmpty || !lines.first.startsWith('#EXTM3U')) {
      throw Exception('Arquivo M3U inválido - cabeçalho #EXTM3U não encontrado');
    }

    final List<Channel> channels = [];
    final List<Movie> movies = [];
    final List<Series> series = [];
    final Set<String> categories = {};

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.startsWith('#EXTINF:')) {
        if (i + 1 < lines.length) {
          final url = lines[i + 1];
          if (!url.startsWith('#') && url.isNotEmpty) {
            final item = _parseExtInfLine(line, url, i.toString());
            categories.add(item['category'] as String);
            
            // Classifica o tipo de conteúdo
            final contentType = _classifyContent(item);
            
            switch (contentType) {
              case ContentType.liveTV:
                channels.add(Channel(
                  id: item['id'] as String,
                  name: item['name'] as String,
                  url: url,
                  logo: item['logo'] as String?,
                  category: item['category'] as String,
                  epgId: item['epg_id'] as String?,
                ));
                break;
              case ContentType.movie:
                movies.add(Movie(
                  id: item['id'] as String,
                  name: item['name'] as String,
                  url: url,
                  poster: item['logo'] as String?,
                  category: item['category'] as String,
                  description: item['description'] as String?,
                  year: item['year'] as String?,
                ));
                break;
              case ContentType.series:
                series.add(Series(
                  id: item['id'] as String,
                  name: item['name'] as String,
                  poster: item['logo'] as String?,
                  category: item['category'] as String,
                  description: item['description'] as String?,
                  year: item['year'] as String?,
                ));
                break;
            }
            i++; // Pula a próxima linha (URL)
          }
        }
      }
    }

    return M3UPlaylist(
      source: source,
      channels: channels,
      movies: movies,
      series: series,
      categories: categories.toList()..sort(),
      loadedAt: DateTime.now(),
    );
  }

  /// Analisa uma linha #EXTINF e extrai as informações
  Map<String, dynamic> _parseExtInfLine(String extinf, String url, String id) {
    final Map<String, dynamic> result = {
      'id': id,
      'name': '',
      'category': 'Sem Categoria',
      'logo': null,
      'epg_id': null,
      'description': null,
      'year': null,
    };

    // Remove #EXTINF: e pega a parte da duração
    final content = extinf.substring(8);
    final parts = content.split(',');
    
    if (parts.length >= 2) {
      final attributes = parts[0];
      final name = parts.sublist(1).join(',').trim();
      result['name'] = name;

      // Extrai atributos usando regex
      final attributePattern = RegExp(r'(\w+)="([^"]*)"');
      final matches = attributePattern.allMatches(attributes);
      
      for (final match in matches) {
        final key = match.group(1)?.toLowerCase();
        final value = match.group(2);
        
        switch (key) {
          case 'tvg-logo':
          case 'logo':
            result['logo'] = value;
            break;
          case 'group-title':
          case 'category':
            result['category'] = value ?? 'Sem Categoria';
            break;
          case 'tvg-id':
          case 'epg-id':
            result['epg_id'] = value;
            break;
          case 'plot':
          case 'description':
            result['description'] = value;
            break;
          case 'year':
          case 'date':
            result['year'] = value;
            break;
        }
      }
    }

    return result;
  }

  /// Classifica o tipo de conteúdo baseado em padrões e heurísticas
  ContentType _classifyContent(Map<String, dynamic> item) {
    final String name = (item['name'] as String).toLowerCase();
    final String category = (item['category'] as String).toLowerCase();
    final String url = item['url'] ?? '';

    // Padrões para identificar TV ao vivo
    final livePatterns = [
      'tv', 'canal', 'channel', 'live', 'ao vivo', 'direto',
      'hd', 'sd', 'fhd', '4k', 'uhd', 
      'news', 'notícias', 'esporte', 'sport', 'documentary',
      'discovery', 'natgeo', 'history', 'cartoon', 'kids',
      'música', 'music', 'radio', 'rádio'
    ];

    // Padrões para identificar filmes
    final moviePatterns = [
      'filme', 'movie', 'cinema', 'film',
      '(19', '(20', // Anos entre parênteses
      'bluray', 'dvdrip', 'hdtv', 'webrip', 'web-dl',
      'action', 'ação', 'terror', 'horror', 'comedy', 'comédia',
      'drama', 'thriller', 'romance', 'ficção'
    ];

    // Padrões para identificar séries
    final seriesPatterns = [
      'série', 'series', 'temporada', 'season', 'episódio', 'episode',
      's01', 's02', 's03', 's04', 's05', 's06', 's07', 's08', 's09', 's10',
      'e01', 'e02', 'e03', 'e04', 'e05', 'e06', 'e07', 'e08', 'e09', 'e10',
      'ep01', 'ep02', 'ep03', 'cap01', 'cap02', 'cap03'
    ];

    // Verifica categorias primeiro
    if (_containsAnyPattern(category, moviePatterns)) {
      return ContentType.movie;
    }
    if (_containsAnyPattern(category, seriesPatterns)) {
      return ContentType.series;
    }
    if (_containsAnyPattern(category, livePatterns)) {
      return ContentType.liveTV;
    }

    // Verifica o nome/título
    if (_containsAnyPattern(name, seriesPatterns)) {
      return ContentType.series;
    }
    if (_containsAnyPattern(name, moviePatterns)) {
      return ContentType.movie;
    }

    // Verifica a URL
    final urlLower = url.toLowerCase();
    if (urlLower.contains('.ts') || urlLower.contains('live') || urlLower.contains(':8080')) {
      return ContentType.liveTV;
    }
    if (urlLower.contains('movie') || urlLower.contains('.mp4') || urlLower.contains('.mkv')) {
      return ContentType.movie;
    }
    if (urlLower.contains('series') || urlLower.contains('episode')) {
      return ContentType.series;
    }

    // Por padrão, considera como TV ao vivo
    return ContentType.liveTV;
  }

  /// Verifica se o texto contém algum dos padrões especificados
  bool _containsAnyPattern(String text, List<String> patterns) {
    final lowerText = text.toLowerCase();
    return patterns.any((pattern) => lowerText.contains(pattern));
  }
}

/// Enumeration para tipos de conteúdo
enum ContentType {
  liveTV,
  movie,
  series,
}
