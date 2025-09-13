import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/media_models.dart';

class XtreamService {
  final String serverUrl;
  final String username;
  final String password;

  XtreamService({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  // Base URL para APIs Xtream
  String get baseUrl => '$serverUrl/player_api.php';

  // Autenticação
  Map<String, String> get authParams => {
    'username': username,
    'password': password,
  };

  // Obter informações do servidor
  Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        ...authParams,
        'action': 'get_server_info',
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao obter info do servidor: $e');
    }
    return null;
  }

  // Obter categorias de TV ao vivo
  Future<List<dynamic>> getLiveTVCategories() async {
    try {
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        ...authParams,
        'action': 'get_live_categories',
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao obter categorias de TV: $e');
    }
    return [];
  }

  // Obter canais de TV ao vivo
  Future<List<Channel>> getLiveChannels({String? categoryId}) async {
    try {
      final params = {
        ...authParams,
        'action': 'get_live_streams',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final url = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Channel(
          id: item['stream_id']?.toString() ?? '',
          name: item['name'] ?? '',
          url: '$serverUrl/live/$username/$password/${item['stream_id']}.ts',
          logo: item['stream_icon'],
          category: item['category_name'] ?? '',
          epgId: item['epg_channel_id'],
        )).toList();
      }
    } catch (e) {
      debugPrint('Erro ao obter canais: $e');
    }
    return [];
  }

  // Obter categorias de filmes
  Future<List<dynamic>> getMovieCategories() async {
    try {
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        ...authParams,
        'action': 'get_vod_categories',
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao obter categorias de filmes: $e');
    }
    return [];
  }

  // Obter filmes
  Future<List<Movie>> getMovies({String? categoryId}) async {
    try {
      final params = {
        ...authParams,
        'action': 'get_vod_streams',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final url = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Movie(
          id: item['stream_id']?.toString() ?? '',
          name: item['name'] ?? '',
          url: '$serverUrl/movie/$username/$password/${item['stream_id']}.${item['container_extension'] ?? 'mp4'}',
          poster: item['stream_icon'],
          category: item['category_name'] ?? '',
          description: item['plot'],
          year: item['releasedate'],
          rating: item['rating']?.toString(),
        )).toList();
      }
    } catch (e) {
      debugPrint('Erro ao obter filmes: $e');
    }
    return [];
  }

  // Obter categorias de séries
  Future<List<dynamic>> getSeriesCategories() async {
    try {
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        ...authParams,
        'action': 'get_series_categories',
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao obter categorias de séries: $e');
    }
    return [];
  }

  // Obter séries
  Future<List<Series>> getSeries({String? categoryId}) async {
    try {
      final params = {
        ...authParams,
        'action': 'get_series',
      };
      
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final url = Uri.parse(baseUrl).replace(queryParameters: params);
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Series(
          id: item['series_id']?.toString() ?? '',
          name: item['name'] ?? '',
          poster: item['cover'],
          category: item['category_name'] ?? '',
          description: item['plot'],
          year: item['releaseDate'],
          rating: item['rating']?.toString(),
        )).toList();
      }
    } catch (e) {
      debugPrint('Erro ao obter séries: $e');
    }
    return [];
  }

  // Obter informações detalhadas de uma série
  Future<Series?> getSeriesInfo(String seriesId) async {
    try {
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        ...authParams,
        'action': 'get_series_info',
        'series_id': seriesId,
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final seriesInfo = data['info'];
        final episodes = data['episodes'] as Map<String, dynamic>? ?? {};
        
        final seasons = episodes.entries.map((entry) {
          final seasonNumber = int.tryParse(entry.key) ?? 0;
          final episodeList = (entry.value as List<dynamic>).map((ep) => Episode(
            id: ep['id']?.toString() ?? '',
            name: ep['title'] ?? '',
            url: '$serverUrl/series/$username/$password/${ep['id']}.${ep['container_extension'] ?? 'mp4'}',
            episodeNumber: int.tryParse(ep['episode_num']?.toString() ?? '0') ?? 0,
            description: ep['info']?['plot'],
            duration: ep['info']?['duration'],
          )).toList();
          
          return Season(
            id: entry.key,
            name: 'Temporada $seasonNumber',
            seasonNumber: seasonNumber,
            episodes: episodeList,
          );
        }).toList();

        return Series(
          id: seriesId,
          name: seriesInfo['name'] ?? '',
          poster: seriesInfo['cover'],
          backdrop: seriesInfo['backdrop_path']?.isNotEmpty == true 
              ? '${seriesInfo['backdrop_path']}'
              : null,
          category: seriesInfo['category'] ?? '',
          description: seriesInfo['plot'],
          year: seriesInfo['releasedate'],
          rating: seriesInfo['rating']?.toString(),
          seasons: seasons,
        );
      }
    } catch (e) {
      debugPrint('Erro ao obter info da série: $e');
    }
    return null;
  }
}
