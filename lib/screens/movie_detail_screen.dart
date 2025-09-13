import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/media_models.dart';
import '../services/download_service.dart';
import '../services/favorites_service.dart';
import 'video_player_screen.dart';
import 'downloads_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieInfo(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildTechnicalInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.movie.poster?.isNotEmpty == true)
              CachedNetworkImage(
                imageUrl: widget.movie.poster!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.movie,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.movie,
                  size: 64,
                  color: Colors.grey,
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
    );
  }

  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.movie.year != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.movie.year.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.movie.rating != null) ...[
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.movie.rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _playMovie(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('ASSISTIR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDownloadOptions(),
            icon: const Icon(Icons.download),
            label: const Text('BAIXAR'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Consumer<FavoritesService>(
          builder: (context, favoritesService, child) {
            final isFavorite = favoritesService.isMovieFavorite(widget.movie);
            return IconButton(
              onPressed: () => _toggleFavorite(),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey[600],
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.all(12),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (widget.movie.description?.isEmpty != false) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopse',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.movie.description!,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildTechnicalInfo() {
    final info = <String, String?>{
      'Ano': widget.movie.year?.toString(),
      'Avaliação': widget.movie.rating?.toString(),
    };

    final validInfo = info.entries
        .where((entry) => entry.value?.isNotEmpty == true)
        .toList();

    if (validInfo.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...validInfo.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '${entry.key}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _playMovie() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          title: widget.movie.name,
          videoUrl: widget.movie.url,
        ),
      ),
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opções de Download',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('Alta Qualidade (HD)'),
              subtitle: const Text('Melhor qualidade, arquivo maior'),
              onTap: () => _downloadMovie('HD'),
            ),
            ListTile(
              leading: const Icon(Icons.sd),
              title: const Text('Qualidade Padrão (SD)'),
              subtitle: const Text('Boa qualidade, arquivo menor'),
              onTap: () => _downloadMovie('SD'),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Qualidade Mobile'),
              subtitle: const Text('Otimizado para dispositivos móveis'),
              onTap: () => _downloadMovie('Mobile'),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadMovie(String quality) async {
    Navigator.pop(context);
    
    // Usar o DownloadService real
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
      
      await downloadService.downloadMovie(widget.movie, quality);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Download adicionado à lista: ${widget.movie.name} ($quality)'),
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

  void _toggleFavorite() {
    final favoritesService = Provider.of<FavoritesService>(context, listen: false);
    final isCurrentlyFavorite = favoritesService.isMovieFavorite(widget.movie);
    
    favoritesService.toggleMovieFavorite(widget.movie);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCurrentlyFavorite 
            ? '${widget.movie.name} removido dos favoritos'
            : '${widget.movie.name} adicionado aos favoritos'
        ),
        backgroundColor: isCurrentlyFavorite ? Colors.orange : Colors.green,
      ),
    );
  }
}
