import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/download_service.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Downloads'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Em progresso', icon: Icon(Icons.download)),
            Tab(text: 'Concluídos', icon: Icon(Icons.download_done)),
          ],
        ),
        actions: [
          Consumer<DownloadService>(
            builder: (context, downloadService, child) {
              return IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: downloadService.downloadHistory.isNotEmpty
                    ? () => _showClearHistoryDialog()
                    : null,
                tooltip: 'Limpar histórico',
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveDownloads(),
          _buildDownloadHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveDownloads() {
    return Consumer<DownloadService>(
      builder: (context, downloadService, child) {
        final activeDownloads = downloadService.downloads;
        
        // Debug para verificar estado dos downloads
        debugPrint('🔍 DownloadsScreen - Active downloads: ${activeDownloads.length}');
        for (int i = 0; i < activeDownloads.length; i++) {
          final download = activeDownloads[i];
          debugPrint('📋 Download $i: ${download.title} - Status: ${download.status} - Progress: ${download.progress}');
        }

        if (activeDownloads.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhum download em progresso',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: activeDownloads.length,
          itemBuilder: (context, index) {
            final download = activeDownloads[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            download.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(download.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Qualidade: ${download.quality}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: download.progress,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(download.progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (download.status == DownloadStatus.downloading)
                              IconButton(
                                icon: const Icon(Icons.pause),
                                onPressed: () => downloadService.pauseDownload(download.id),
                                tooltip: 'Pausar',
                              ),
                            if (download.status == DownloadStatus.paused)
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () => downloadService.resumeDownload(download.id),
                                tooltip: 'Continuar',
                              ),
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () => downloadService.cancelDownload(download.id),
                              tooltip: 'Cancelar',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadHistory() {
    return Consumer<DownloadService>(
      builder: (context, downloadService, child) {
        final history = downloadService.downloadHistory;

        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_done_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhum download concluído',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final download = history[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(
                  download.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qualidade: ${download.quality}'),
                    if (download.downloadedAt != null)
                      Text(
                        'Concluído em: ${_formatDate(download.downloadedAt!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text('Reproduzir'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remover'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'play':
                        _playDownload(download);
                        break;
                      case 'delete':
                        downloadService.removeFromHistory(download.id);
                        break;
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(DownloadStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case DownloadStatus.downloading:
        color = Colors.blue;
        text = 'Baixando';
        icon = Icons.download;
        break;
      case DownloadStatus.paused:
        color = Colors.orange;
        text = 'Pausado';
        icon = Icons.pause;
        break;
      case DownloadStatus.completed:
        color = Colors.green;
        text = 'Concluído';
        icon = Icons.check;
        break;
      case DownloadStatus.failed:
        color = Colors.red;
        text = 'Falhou';
        icon = Icons.error;
        break;
      case DownloadStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelado';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'Pendente';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text(
          'Tem certeza que deseja limpar todo o histórico de downloads? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadService>().clearHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _playDownload(DownloadItem download) {
    if (download.localPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            title: download.title,
            videoUrl: 'file://${download.localPath}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} às '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
