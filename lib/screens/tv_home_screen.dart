import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../services/favorites_service.dart';
import '../models/media_models.dart';
import '../widgets/tv_focusable_widgets.dart';
import '../widgets/tv_navigation_wrapper.dart';
import 'tv_video_player_screen.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';
import 'settings_screen.dart';

/// Tela principal otimizada para Android TV com layout horizontal estilo Netflix
class TvHomeScreen extends StatefulWidget {
  const TvHomeScreen({super.key});

  @override
  State<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends State<TvHomeScreen> {
  int _selectedNavIndex = 0;
  final List<TvNavigationRailItem> _navItems = const [
    TvNavigationRailItem(
      icon: Icons.live_tv_outlined,
      selectedIcon: Icons.live_tv,
      label: 'TV ao Vivo',
    ),
    TvNavigationRailItem(
      icon: Icons.movie_outlined,
      selectedIcon: Icons.movie,
      label: 'Filmes',
    ),
    TvNavigationRailItem(
      icon: Icons.tv_outlined,
      selectedIcon: Icons.tv,
      label: 'Séries',
    ),
    TvNavigationRailItem(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Favoritos',
    ),
    TvNavigationRailItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Configurações',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeContent();
    });
  }

  void _initializeContent() {
    final contentService = Provider.of<ContentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isAuthenticated) {
      final credentials = authService.getStoredCredentials();
      final authMethod = credentials['authMethod'] as AuthMethod;

      switch (authMethod) {
        case AuthMethod.xtream:
          contentService.initializeXtream(
            credentials['serverUrl'] as String,
            credentials['username'] as String,
            credentials['password'] as String,
          );
          break;
        case AuthMethod.m3uUrl:
        case AuthMethod.m3uFile:
          contentService.initializeM3U();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TvNavigationWrapper(
      onBackPressed: _handleBack,
      child: Scaffold(
        body: Row(
          children: [
            // Barra de navegação lateral
            TvNavigationRail(
              items: _navItems,
              selectedIndex: _selectedNavIndex,
              onItemSelected: (index) {
                setState(() => _selectedNavIndex = index);
              },
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.tv, size: 32, color: Color(0xFF1565C0)),
                    const SizedBox(width: 12),
                    const Text(
                      'TarTV',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: IndexedStack(
                index: _selectedNavIndex,
                children: [
                  _buildLiveContent(),
                  _buildMoviesContent(),
                  _buildSeriesContent(),
                  _buildFavoritesContent(),
                  const SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (_selectedNavIndex != 0) {
      setState(() => _selectedNavIndex = 0);
    } else {
      _showExitDialog();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do TarTV?'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TvFocusableButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          TvFocusableButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            backgroundColor: Colors.red,
            focusedBackgroundColor: Colors.red.shade700,
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveContent() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingChannels) {
          return const Center(child: CircularProgressIndicator());
        }

        final channels = contentService.channels;
        final categories = _groupChannelsByCategory(channels);

        if (categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum canal disponível'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories.keys.elementAt(index);
            final categoryChannels = categories[category]!;

            return TvHorizontalFocusGroup(
              title: category,
              itemWidth: 200,
              itemHeight: 150,
              children: categoryChannels.map((channel) {
                return _buildChannelCard(channel);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Map<String, List<Channel>> _groupChannelsByCategory(List<Channel> channels) {
    final Map<String, List<Channel>> grouped = {};
    for (final channel in channels) {
      final category = channel.category.isNotEmpty ? channel.category : 'Outros';
      grouped.putIfAbsent(category, () => []).add(channel);
    }
    return grouped;
  }

  Widget _buildChannelCard(Channel channel) {
    return TvFocusableCard(
      onSelect: () => _playChannel(channel),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: channel.logo != null && channel.logo!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: channel.logo!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Icon(Icons.tv, size: 48),
                    errorWidget: (_, __, ___) => const Icon(Icons.tv, size: 48),
                  )
                : const Icon(Icons.tv, size: 48),
          ),
          const SizedBox(height: 8),
          Text(
            channel.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _playChannel(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TvVideoPlayerScreen(
          videoUrl: channel.url,
          title: channel.name,
        ),
      ),
    );
  }

  Widget _buildMoviesContent() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingMovies) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = contentService.movies;
        final categories = _groupMoviesByCategory(movies);

        if (categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum filme disponível'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories.keys.elementAt(index);
            final categoryMovies = categories[category]!;

            return TvHorizontalFocusGroup(
              title: category,
              itemWidth: 180,
              itemHeight: 280,
              children: categoryMovies.map((movie) {
                return _buildMovieCard(movie);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Map<String, List<Movie>> _groupMoviesByCategory(List<Movie> movies) {
    final Map<String, List<Movie>> grouped = {};
    for (final movie in movies) {
      final category = movie.category.isNotEmpty ? movie.category : 'Outros';
      grouped.putIfAbsent(category, () => []).add(movie);
    }
    return grouped;
  }

  Widget _buildMovieCard(Movie movie) {
    return TvFocusableCard(
      onSelect: () => _openMovieDetail(movie),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: movie.poster != null && movie.poster!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.poster!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.movie, size: 48, color: Colors.white54),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.movie, size: 48, color: Colors.white54),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie, size: 48, color: Colors.white54),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              movie.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _openMovieDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  Widget _buildSeriesContent() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingSeries) {
          return const Center(child: CircularProgressIndicator());
        }

        final series = contentService.series;
        final categories = _groupSeriesByCategory(series);

        if (categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhuma série disponível'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories.keys.elementAt(index);
            final categorySeries = categories[category]!;

            return TvHorizontalFocusGroup(
              title: category,
              itemWidth: 180,
              itemHeight: 280,
              children: categorySeries.map((s) {
                return _buildSeriesCard(s);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Map<String, List<Series>> _groupSeriesByCategory(List<Series> series) {
    final Map<String, List<Series>> grouped = {};
    for (final s in series) {
      final category = s.category.isNotEmpty ? s.category : 'Outros';
      grouped.putIfAbsent(category, () => []).add(s);
    }
    return grouped;
  }

  Widget _buildSeriesCard(Series series) {
    return TvFocusableCard(
      onSelect: () => _openSeriesDetail(series),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: series.poster != null && series.poster!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: series.poster!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.tv, size: 48, color: Colors.white54),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.tv, size: 48, color: Colors.white54),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.tv, size: 48, color: Colors.white54),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              series.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _openSeriesDetail(Series series) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeriesDetailScreen(series: series),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return Consumer2<FavoritesService, ContentService>(
      builder: (context, favoritesService, contentService, child) {
        final favoriteChannels = favoritesService.favoriteChannels;
        final favoriteMovies = favoritesService.favoriteMovies;
        final favoriteSeries = favoritesService.favoriteSeries;

        if (favoriteChannels.isEmpty &&
            favoriteMovies.isEmpty &&
            favoriteSeries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum favorito adicionado'),
                SizedBox(height: 8),
                Text(
                  'Adicione canais, filmes ou séries aos favoritos',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            if (favoriteChannels.isNotEmpty)
              TvHorizontalFocusGroup(
                title: 'Canais Favoritos',
                itemWidth: 200,
                itemHeight: 150,
                children: favoriteChannels.map((c) => _buildChannelCard(c)).toList(),
              ),
            if (favoriteMovies.isNotEmpty)
              TvHorizontalFocusGroup(
                title: 'Filmes Favoritos',
                itemWidth: 180,
                itemHeight: 280,
                children: favoriteMovies.map((m) => _buildMovieCard(m)).toList(),
              ),
            if (favoriteSeries.isNotEmpty)
              TvHorizontalFocusGroup(
                title: 'Séries Favoritas',
                itemWidth: 180,
                itemHeight: 280,
                children: favoriteSeries.map((s) => _buildSeriesCard(s)).toList(),
              ),
          ],
        );
      },
    );
  }
}
