class Channel {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String category;
  final String? epgId;

  Channel({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    required this.category,
    this.epgId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      logo: json['logo'],
      category: json['category'] ?? '',
      epgId: json['epg_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'logo': logo,
      'category': category,
      'epg_id': epgId,
    };
  }
}

class Movie {
  final String id;
  final String name;
  final String url;
  final String? poster;
  final String? backdrop;
  final String category;
  final String? description;
  final String? year;
  final String? rating;
  final DateTime? addedAt;

  // Alias para compatibilidade
  String get streamId => id;

  Movie({
    required this.id,
    required this.name,
    required this.url,
    this.poster,
    this.backdrop,
    required this.category,
    this.description,
    this.year,
    this.rating,
    this.addedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      poster: json['poster'],
      backdrop: json['backdrop'],
      category: json['category'] ?? '',
      description: json['description'],
      year: json['year']?.toString(),
      rating: json['rating']?.toString(),
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'poster': poster,
      'backdrop': backdrop,
      'category': category,
      'description': description,
      'year': year,
      'rating': rating,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}

class Series {
  final String id;
  final String name;
  final String? poster;
  final String? backdrop;
  final String category;
  final String? description;
  final String? year;
  final String? rating;
  final List<Season> seasons;
  final DateTime? addedAt;

  // Alias para compatibilidade
  String get seriesId => id;

  Series({
    required this.id,
    required this.name,
    this.poster,
    this.backdrop,
    required this.category,
    this.description,
    this.year,
    this.rating,
    this.seasons = const [],
    this.addedAt,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      poster: json['poster'],
      backdrop: json['backdrop'],
      category: json['category'] ?? '',
      description: json['description'],
      year: json['year']?.toString(),
      rating: json['rating']?.toString(),
      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((season) => Season.fromJson(season))
          .toList() ?? [],
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
    );
  }

  get url => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'poster': poster,
      'backdrop': backdrop,
      'category': category,
      'description': description,
      'year': year,
      'rating': rating,
      'seasons': seasons.map((season) => season.toJson()).toList(),
      'added_at': addedAt?.toIso8601String(),
    };
  }
}

class Season {
  final String id;
  final String name;
  final int seasonNumber;
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.name,
    required this.seasonNumber,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((episode) => Episode.fromJson(episode))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'season_number': seasonNumber,
      'episodes': episodes.map((episode) => episode.toJson()).toList(),
    };
  }
}

class Episode {
  final String id;
  final String name;
  final String url;
  final int episodeNumber;
  final String? description;
  final String? duration;

  Episode({
    required this.id,
    required this.name,
    required this.url,
    required this.episodeNumber,
    this.description,
    this.duration,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      description: json['description'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'episode_number': episodeNumber,
      'description': description,
      'duration': duration,
    };
  }
}

/// Classe para representar uma playlist M3U processada
class M3UPlaylist {
  final String source;
  final List<Channel> channels;
  final List<Movie> movies;
  final List<Series> series;
  final List<String> categories;
  final DateTime loadedAt;

  M3UPlaylist({
    required this.source,
    required this.channels,
    required this.movies,
    required this.series,
    required this.categories,
    required this.loadedAt,
  });

  int get totalItems => channels.length + movies.length + series.length;
  
  @override
  String toString() {
    return 'M3UPlaylist(source: $source, channels: ${channels.length}, movies: ${movies.length}, series: ${series.length}, categories: ${categories.length})';
  }
}
