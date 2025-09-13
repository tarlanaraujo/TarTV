import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/content_service.dart';
import '../services/favorites_service.dart';
import '../models/media_models.dart';
import 'video_player_screen.dart';
import 'advanced_search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchResults? _results;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final contentService = Provider.of<ContentService>(context, listen: false);
    final results = contentService.search(query.trim());

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Busca Avançada',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite para buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: _performSearch,
              autofocus: true,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Digite algo para buscar',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (!_results!.hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado para "${_results!.query}"',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_results!.channels.isNotEmpty) ...[
          _buildSectionHeader('Canais (${_results!.channels.length})'),
          const SizedBox(height: 8),
          ..._results!.channels.map((channel) => _buildChannelTile(channel)),
          const SizedBox(height: 16),
        ],
        if (_results!.movies.isNotEmpty) ...[
          _buildSectionHeader('Filmes (${_results!.movies.length})'),
          const SizedBox(height: 8),
          ..._results!.movies.map((movie) => _buildMovieTile(movie)),
          const SizedBox(height: 16),
        ],
        if (_results!.series.isNotEmpty) ...[
          _buildSectionHeader('Séries (${_results!.series.length})'),
          const SizedBox(height: 8),
          ..._results!.series.map((series) => _buildSeriesTile(series)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildChannelTile(Channel channel) {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, _) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: channel.logo != null
                  ? ClipOval(
                      child: Image.network(
                        channel.logo!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.live_tv, color: Colors.white);
                        },
                      ),
                    )
                  : const Icon(Icons.live_tv, color: Colors.white),
            ),
            title: Text(
              channel.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(channel.category),
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
                        : Colors.grey,
                  ),
                  onPressed: () {
                    favoritesService.toggleChannelFavorite(channel);
                  },
                ),
                const Icon(Icons.play_arrow),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    title: channel.name,
                    videoUrl: channel.url,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMovieTile(Movie movie) {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, _) {
        return Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: movie.poster != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.poster!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.movie, color: Colors.white);
                        },
                      ),
                    )
                  : const Icon(Icons.movie, color: Colors.white),
            ),
            title: Text(
              movie.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.category),
                if (movie.year != null) Text('Ano: ${movie.year}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    favoritesService.isMovieFavorite(movie)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoritesService.isMovieFavorite(movie)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    favoritesService.toggleMovieFavorite(movie);
                  },
                ),
                const Icon(Icons.play_arrow),
              ],
            ),
            onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(title: movie.name, videoUrl: movie.url),
                    ),
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildSeriesTile(Series series) {
    return Consumer<FavoritesService>(
      builder: (context, favoritesService, _) {
        return Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: series.poster != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        series.poster!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.tv, color: Colors.white);
                        },
                      ),
                    )
                  : const Icon(Icons.tv, color: Colors.white),
            ),
            title: Text(
              series.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(series.category),
                if (series.year != null) Text('Ano: ${series.year}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    favoritesService.isSeriesFavorite(series)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoritesService.isSeriesFavorite(series)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    favoritesService.toggleSeriesFavorite(series);
                  },
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      title: series.name,
                      videoUrl: series.url,
                    ),
                  ),
                );
            },
          ),
        );
      },
    );
  }
}
