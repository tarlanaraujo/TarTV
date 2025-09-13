import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/media_models.dart';
import '../services/content_service.dart';
import '../services/download_service.dart';
import '../services/favorites_service.dart';
import 'video_player_screen.dart';
import 'downloads_screen.dart';

class SeriesDetailScreen extends StatefulWidget {
  final Series series;

  const SeriesDetailScreen({
    super.key,
    required this.series,
  });

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  Series? _detailedSeries;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeriesDetails();
  }

  Future<void> _loadSeriesDetails() async {
    try {
      final contentService = Provider.of<ContentService>(context, listen: false);
      final detailedSeries = await contentService.getSeriesInfo(widget.series.id);
      
      setState(() {
        _detailedSeries = detailedSeries ?? widget.series;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _detailedSeries = widget.series;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.series.name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.series.backdrop != null
                      ? Image.network(
                          widget.series.backdrop!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.blue, Colors.indigo],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.blue, Colors.indigo],
                            ),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.series.poster != null
                              ? Image.network(
                                  widget.series.poster!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.tv,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.tv,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informações
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.series.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (widget.series.year != null)
                              Chip(
                                label: Text(widget.series.year!),
                                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Categoria: ${widget.series.category}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (widget.series.rating != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.series.rating!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Botões de ação
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<FavoritesService>(
                        builder: (context, favoritesService, child) {
                          final isFavorite = favoritesService.isSeriesFavorite(widget.series);
                          return IconButton(
                            onPressed: () {
                              final favoritesService = Provider.of<FavoritesService>(context, listen: false);
                              favoritesService.toggleSeriesFavorite(widget.series);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    favoritesService.isSeriesFavorite(widget.series)
                                        ? '${widget.series.name} adicionada aos favoritos'
                                        : '${widget.series.name} removida dos favoritos',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                              size: 28,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.all(12),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  if (widget.series.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Sinopse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.series.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  Text(
                    'Temporadas e Episódios',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(height: 8),
                        const Text(
                          'Informações detalhadas não disponíveis',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exibindo informações básicas da série.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_detailedSeries!.seasons.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final season = _detailedSeries!.seasons[index];
                  return _SeasonCard(season: season);
                },
                childCount: _detailedSeries!.seasons.length,
              ),
            )
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.tv_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum episódio disponível',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatefulWidget {
  final Season season;

  const _SeasonCard({required this.season});

  @override
  State<_SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends State<_SeasonCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.season.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.season.episodes.length} episódios'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...widget.season.episodes.map((episode) => _EpisodeTile(episode: episode)),
          ],
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;

  const _EpisodeTile({required this.episode});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          episode.episodeNumber.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(episode.name),
      subtitle: episode.description != null
          ? Text(
              episode.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    title: episode.name,
                    videoUrl: episode.url,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'download_hd') {
                _downloadEpisode(context, 'HD');
              } else if (value == 'download_sd') {
                _downloadEpisode(context, 'SD');
              } else if (value == 'download_mobile') {
                _downloadEpisode(context, 'Mobile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download_hd',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Download HD'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download_sd',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Download SD'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download_mobile',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Download Mobile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              title: episode.name,
              videoUrl: episode.url,
            ),
          ),
        );
      },
    );
  }
  
  void _downloadEpisode(BuildContext context, String quality) async {
    final downloadService = Provider.of<DownloadService>(context, listen: false);
    
    try {
      // Verificar permissões primeiro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔐 Verificando permissões de armazenamento...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Aguardar um pouco para mostrar a mensagem
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Precisamos criar objetos Series e Season para o download
      // Como não temos acesso direto aqui, vamos criar objetos básicos
      final series = Series(
        id: '0',
        name: 'Série',
        category: 'series',
        seasons: [],
      );
      
      final season = Season(
        id: '1',
        seasonNumber: 1,
        name: 'Temporada 1',
        episodes: [episode],
      );
      
      await downloadService.downloadSeries(series, season, episode, quality);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Download adicionado à lista: ${episode.name} ($quality)'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver downloads',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadsScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      String errorMessage = 'Erro ao iniciar download: $e';
      
      if (e.toString().contains('Permissão de armazenamento negada')) {
        errorMessage = '🔒 Permissão de armazenamento negada. \nVá em Configurações > Apps > TarTV > Permissões e conceda acesso ao armazenamento.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Configurações',
            textColor: Colors.white,
            onPressed: () async {
              await openAppSettings();
            },
          ),
        ),
      );
    }
  }
}
