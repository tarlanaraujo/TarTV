import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../models/media_models.dart';
import 'video_player_screen.dart';
import 'series_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.live_tv),
              text: 'Canais',
            ),
            Tab(
              icon: Icon(Icons.movie),
              text: 'Filmes',
            ),
            Tab(
              icon: Icon(Icons.tv),
              text: 'Séries',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChannelsFavorites(),
          _buildMoviesFavorites(),
          _buildSeriesFavorites(),
        ],
      ),
    );
  }

  Widget _buildChannelsFavorites() {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final favoriteChannels = favoritesService.favoriteChannels;

        if (favoriteChannels.isEmpty) {
          return _buildEmptyState(
            icon: Icons.live_tv,
            title: 'Nenhum canal favorito',
            subtitle: 'Adicione canais aos favoritos para vê-los aqui',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: favoriteChannels.length,
          itemBuilder: (context, index) {
            final channel = favoriteChannels[index];
            return _buildChannelItem(channel, favoritesService);
          },
        );
      },
    );
  }

  Widget _buildMoviesFavorites() {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final favoriteMovies = favoritesService.favoriteMovies;

        if (favoriteMovies.isEmpty) {
          return _buildEmptyState(
            icon: Icons.movie,
            title: 'Nenhum filme favorito',
            subtitle: 'Adicione filmes aos favoritos para vê-los aqui',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: favoriteMovies.length,
          itemBuilder: (context, index) {
            final movie = favoriteMovies[index];
            return _buildMovieItem(movie, favoritesService);
          },
        );
      },
    );
  }

  Widget _buildSeriesFavorites() {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, child) {
        final favoriteSeries = favoritesService.favoriteSeries;

        if (favoriteSeries.isEmpty) {
          return _buildEmptyState(
            icon: Icons.tv,
            title: 'Nenhuma série favorita',
            subtitle: 'Adicione séries aos favoritos para vê-las aqui',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: favoriteSeries.length,
          itemBuilder: (context, index) {
            final series = favoriteSeries[index];
            return _buildSeriesItem(series, favoritesService);
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(Channel channel, FavoritesService favoritesService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            width: 50,
            height: 50,
            child: channel.logo != null && channel.logo!.isNotEmpty
                ? Image.network(
                    channel.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.live_tv),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.live_tv),
                  ),
          ),
        ),
        title: Text(
          channel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          channel.category,
         
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                favoritesService.isChannelFavorite(channel)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoritesService.isChannelFavorite(channel)
                    ? Colors.red
                    : null,
              ),
              onPressed: () {
                favoritesService.toggleChannelFavorite(channel);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _playChannel(channel),
            ),
          ],
        ),
        onTap: () => _playChannel(channel),
      ),
    );
  }

  Widget _buildMovieItem(Movie movie, FavoritesService favoritesService) {
    return Card(
      child: InkWell(
        onTap: () => _playMovie(movie),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: movie.poster != null && movie.poster!.isNotEmpty
                    ? Image.network(
                        movie.poster!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 40),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          movie.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          favoritesService.isMovieFavorite(movie)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoritesService.isMovieFavorite(movie)
                              ? Colors.red
                              : null,
                          size: 20,
                        ),
                        onPressed: () {
                          favoritesService.toggleMovieFavorite(movie);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesItem(Series series, FavoritesService favoritesService) {
    return Card(
      child: InkWell(
        onTap: () => _openSeriesDetail(series),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: series.poster != null && series.poster!.isNotEmpty
                    ? Image.network(
                        series.poster!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.tv, size: 40),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.tv, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          series.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          favoritesService.isSeriesFavorite(series)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoritesService.isSeriesFavorite(series)
                              ? Colors.red
                              : null,
                          size: 20,
                        ),
                        onPressed: () {
                          favoritesService.toggleSeriesFavorite(series);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playChannel(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: channel.url,
          title: channel.name,
        ),
      ),
    );
  }

  void _playMovie(Movie movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(title: movie.name, videoUrl: movie.url),
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
}
