import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../services/layout_service.dart';
import '../services/favorites_service.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/series_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _movieSearchQuery = '';
  String _seriesSearchQuery = '';
  String _channelSearchQuery = '';
  final TextEditingController _movieSearchController = TextEditingController();
  final TextEditingController _seriesSearchController = TextEditingController();
  final TextEditingController _channelSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  void dispose() {
    _movieSearchController.dispose();
    _seriesSearchController.dispose();
    _channelSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TarTV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildLiveTab(),
          _buildMoviesTab(),
          _buildSeriesTab(),
          const FavoritesScreen(),
          const DownloadsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'Ao Vivo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Séries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingChannels) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (contentService.channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nenhum canal encontrado'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => contentService.loadLiveChannels(),
                  child: const Text('Carregar canais'),
                ),
              ],
            ),
          );
        }

        // Filtrar canais pela busca
        final filteredChannels = _channelSearchQuery.isEmpty
            ? contentService.channels
            : contentService.channels
                .where((channel) => channel.name.toLowerCase().contains(_channelSearchQuery.toLowerCase()))
                .toList();
        
        return Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _channelSearchController,
                decoration: InputDecoration(
                  hintText: 'Buscar canais...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _channelSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _channelSearchController.clear();
                            setState(() {
                              _channelSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _channelSearchQuery = value;
                  });
                },
              ),
            ),
            // Grid de canais
            Expanded(
              child: Consumer<LayoutService>(
                builder: (context, layoutService, child) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: layoutService.gridColumns,
                      childAspectRatio: 1.2, // Mais quadrado para canais
                      crossAxisSpacing: layoutService.getItemSpacing(),
                      mainAxisSpacing: layoutService.getItemSpacing(),
                    ),
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredChannels.length,
                    itemBuilder: (context, index) {
                      final channel = filteredChannels[index];
                      return Card(
                        child: Stack(
                          children: [
                            InkWell(
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: channel.logo != null 
                                        ? Image.network(
                                            channel.logo!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.tv, size: 48),
                                          )
                                        : const Icon(Icons.tv, size: 48),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            channel.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          if (channel.category.isNotEmpty)
                                            Text(
                                              channel.category,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Botão de favorito no canto superior direito
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Consumer<FavoritesService>(
                                builder: (context, favoritesService, child) {
                                  final isFavorite = favoritesService.isChannelFavorite(channel);
                                  return InkWell(
                                    onTap: () {
                                      favoritesService.toggleChannelFavorite(channel);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFavorite 
                                                ? '${channel.name} removido dos favoritos' 
                                                : '${channel.name} adicionado aos favoritos',
                                          ),
                                          backgroundColor: isFavorite ? Colors.orange : Colors.green,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoviesTab() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingMovies) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (contentService.movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nenhum filme encontrado'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => contentService.loadMovies(),
                  child: const Text('Carregar filmes'),
                ),
              ],
            ),
          );
        }

        // Filtrar filmes pela busca
        final filteredMovies = _movieSearchQuery.isEmpty
            ? contentService.movies
            : contentService.movies
                .where((movie) => movie.name.toLowerCase().contains(_movieSearchQuery.toLowerCase()))
                .toList();
        
        return Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _movieSearchController,
                decoration: InputDecoration(
                  hintText: 'Buscar filmes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _movieSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _movieSearchController.clear();
                            setState(() {
                              _movieSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _movieSearchQuery = value;
                  });
                },
              ),
            ),
            // Grid de filmes
            Expanded(
              child: Consumer<LayoutService>(
                builder: (context, layoutService, child) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: layoutService.gridColumns,
                      childAspectRatio: layoutService.getItemAspectRatio(),
                      crossAxisSpacing: layoutService.getItemSpacing(),
                      mainAxisSpacing: layoutService.getItemSpacing(),
                    ),
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen(movie: movie),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: movie.poster != null
                                  ? Image.network(
                                      movie.poster!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.movie, size: 64),
                                    )
                                  : const Center(child: Icon(Icons.movie, size: 64)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (movie.year != null)
                                      Text(
                                        movie.year!,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeriesTab() {
    return Consumer<ContentService>(
      builder: (context, contentService, child) {
        if (contentService.isLoadingSeries) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (contentService.series.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nenhuma série encontrada'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => contentService.loadSeries(),
                  child: const Text('Carregar séries'),
                ),
              ],
            ),
          );
        }

        // Filtrar séries pela busca
        final filteredSeries = _seriesSearchQuery.isEmpty
            ? contentService.series
            : contentService.series
                .where((series) => series.name.toLowerCase().contains(_seriesSearchQuery.toLowerCase()))
                .toList();
        
        return Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _seriesSearchController,
                decoration: InputDecoration(
                  hintText: 'Buscar séries...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _seriesSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _seriesSearchController.clear();
                            setState(() {
                              _seriesSearchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _seriesSearchQuery = value;
                  });
                },
              ),
            ),
            // Grid de séries
            Expanded(
              child: Consumer<LayoutService>(
                builder: (context, layoutService, child) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: layoutService.gridColumns,
                      childAspectRatio: layoutService.getItemAspectRatio(),
                      crossAxisSpacing: layoutService.getItemSpacing(),
                      mainAxisSpacing: layoutService.getItemSpacing(),
                    ),
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredSeries.length,
                    itemBuilder: (context, index) {
                      final series = filteredSeries[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeriesDetailScreen(series: series),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: series.poster != null
                                  ? Image.network(
                                      series.poster!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.tv, size: 64),
                                    )
                                  : const Center(child: Icon(Icons.tv, size: 64)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      series.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (series.year != null)
                                      Text(
                                        series.year!,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
