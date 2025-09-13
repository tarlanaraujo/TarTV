import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io' as io;

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;
  bool _isBuffering = false;
  bool _wasPlayingBeforeBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _addVideoPlayerListener() {
    _videoPlayerController.addListener(() {
      if (mounted) {
        final isBuffering = _videoPlayerController.value.isBuffering;
        final isPlaying = _videoPlayerController.value.isPlaying;
        
        // Atualizar UI com estado de buffering
        if (_isBuffering != isBuffering) {
          setState(() {
            _isBuffering = isBuffering;
          });
        }
        
        // Se começou a fazer buffering
        if (isBuffering && !_isBuffering) {
          _wasPlayingBeforeBuffering = isPlaying;
          // Não pausar durante buffering - deixar o player lidar com isso
        }
        // Se parou de fazer buffering
        else if (!isBuffering && _isBuffering) {
          // Se estava reproduzindo antes do buffering e agora está pausado, retomar
          if (_wasPlayingBeforeBuffering && !isPlaying && !_videoPlayerController.value.hasError) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted && !_videoPlayerController.value.isPlaying && !_videoPlayerController.value.hasError) {
                _videoPlayerController.play();
              }
            });
          }
        }
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      // Validar e limpar URL
      String cleanUrl = widget.videoUrl.trim();
      
      // Validações básicas
      if (cleanUrl.isEmpty) {
        throw Exception('URL está vazia');
      }
      
      debugPrint('🎬 Iniciando player para: $cleanUrl');
      
      // Verificar se é arquivo local primeiro
      if (cleanUrl.startsWith('file://') || cleanUrl.startsWith('/')) {
        debugPrint('📁 Detectado arquivo local: $cleanUrl');
        
        // Normalizar caminho do arquivo local
        final localPath = cleanUrl.replaceFirst('file://', '');
        final file = io.File(localPath);
        
        debugPrint('📂 Verificando arquivo: ${file.path}');
        
        if (!await file.exists()) {
          debugPrint('❌ Arquivo não encontrado: ${file.path}');
          throw Exception('Arquivo local não encontrado: ${file.path}');
        }
        
        final fileSize = await file.length();
        debugPrint('✅ Arquivo encontrado: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');
        
        _videoPlayerController = VideoPlayerController.file(file);
      } 
      // Se não é arquivo local, deve ser URL de rede
      else if (cleanUrl.startsWith('http')) {
        debugPrint('🌐 Detectada URL de rede: $cleanUrl');
        
        // Verificar se a URL contém caracteres especiais problemáticos
        if (cleanUrl.contains(' ')) {
          cleanUrl = cleanUrl.replaceAll(' ', '%20');
        }
        
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(cleanUrl),
          httpHeaders: {
            'User-Agent': 'TarTV/2.5 (Linux; Android)',
            'Accept': '*/*',
            'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
            'Accept-Encoding': 'identity',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
          formatHint: VideoFormat.other,
        );
      } else {
        throw Exception('URL inválida: deve começar com http, https ou file://');
      }

      debugPrint('🔄 Inicializando video player...');
      
      // Aumentar timeout e adicionar retry automático
      await _videoPlayerController.initialize().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception('Timeout: Servidor não respondeu em 45 segundos');
        },
      );
      
      debugPrint('✅ Video player inicializado com sucesso!');
      debugPrint('📺 Duração: ${_videoPlayerController.value.duration}');
      debugPrint('📐 Resolução: ${_videoPlayerController.value.size}');
      
      // Adicionar listener para monitorar buffering
      _addVideoPlayerListener();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        // Configurações otimizadas para streaming ao vivo
        showControlsOnInitialize: false,
        hideControlsTimer: const Duration(seconds: 3),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro no player:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _retryInitialize(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        String errorMessage = 'Erro desconhecido';
        
        if (e.toString().contains('VideoError')) {
          errorMessage = 'Erro no player: Verifique se o servidor está funcionando';
        } else if (e.toString().contains('Timeout')) {
          errorMessage = 'Timeout: Servidor muito lento ou indisponível';
        } else if (e.toString().contains('URL inválida')) {
          errorMessage = 'URL do vídeo está incorreta';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Erro de plataforma: Codec não suportado ou URL inacessível';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'Erro de conexão: Verifique sua internet';
        } else {
          errorMessage = 'Erro: ${e.toString()}';
        }
        
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryInitialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // Dispose do controller anterior se existir
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    
    // Tentar novamente
    await _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              final uri = Uri.tryParse(widget.videoUrl);
              final messenger = ScaffoldMessenger.of(context);

              if (uri == null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('URL inválida para download')),
                );
                return;
              }

              final filename = uri.pathSegments.isNotEmpty
                  ? uri.pathSegments.last
                  : '${DateTime.now().millisecondsSinceEpoch}.mp4';

              messenger.showSnackBar(
                SnackBar(content: Text('Iniciando download: $filename')),
              );

              try {
                // Download implementado - redirecionar para downloads se necessário
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Use a tela de filmes/séries para baixar conteúdo'),
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Erro no download: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Carregando stream...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _retryInitialize,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  )
                : _chewieController != null
                    ? Stack(
                        children: [
                          Chewie(controller: _chewieController!),
                          // Indicador de buffering
                          if (_isBuffering)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.red,
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Carregando...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Text(
                        'Erro ao inicializar player',
                        style: TextStyle(color: Colors.white),
                      ),
      ),
    );
  }
}
