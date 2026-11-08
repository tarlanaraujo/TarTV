import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

/// Player de vídeo otimizado para Android TV com controles por D-pad
class TvVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const TvVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<TvVideoPlayerScreen> createState() => _TvVideoPlayerScreenState();
}

class _TvVideoPlayerScreenState extends State<TvVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isBuffering = false;

  // Constantes para seek
  static const int _seekSeconds = 10;
  static const int _longSeekSeconds = 30;

  final FocusNode _playerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideControlsTimer();
    
    // Forçar modo paisagem fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    _playerFocusNode.dispose();
    
    // Restaurar orientações
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('📺 TV Player: Iniciando $widget.videoUrl');
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: const {
          'User-Agent': 'TarTV/1.0',
        },
      );

      _controller.addListener(_videoListener);

      await _controller.initialize();
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ TV Player erro: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      final isBuffering = _controller.value.isBuffering;
      if (_isBuffering != isBuffering) {
        setState(() {
          _isBuffering = isBuffering;
        });
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      _controller.play();
      _startHideControlsTimer();
    }
    setState(() {});
  }

  void _seekForward([int seconds = _seekSeconds]) {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    final newPosition = currentPosition + Duration(seconds: seconds);
    
    if (newPosition < duration) {
      _controller.seekTo(newPosition);
    } else {
      _controller.seekTo(duration);
    }
    _showControlsTemporarily();
  }

  void _seekBackward([int seconds = _seekSeconds]) {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - Duration(seconds: seconds);
    
    if (newPosition > Duration.zero) {
      _controller.seekTo(newPosition);
    } else {
      _controller.seekTo(Duration.zero);
    }
    _showControlsTemporarily();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      // Play/Pause com OK, Enter, Espaço ou botão Play
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.mediaPlayPause:
        _togglePlayPause();
        return KeyEventResult.handled;

      // Seek com setas esquerda/direita
      case LogicalKeyboardKey.arrowLeft:
        _seekBackward();
        return KeyEventResult.handled;
      
      case LogicalKeyboardKey.arrowRight:
        _seekForward();
        return KeyEventResult.handled;

      // Long seek com Page Up/Down ou setas + Shift
      case LogicalKeyboardKey.pageUp:
        _seekForward(_longSeekSeconds);
        return KeyEventResult.handled;
      
      case LogicalKeyboardKey.pageDown:
        _seekBackward(_longSeekSeconds);
        return KeyEventResult.handled;

      // Setas cima/baixo para mostrar controles ou volume
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
        _showControlsTemporarily();
        return KeyEventResult.handled;

      // Voltar
      case LogicalKeyboardKey.goBack:
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.browserBack:
        Navigator.of(context).pop();
        return KeyEventResult.handled;

      // Controles de mídia
      case LogicalKeyboardKey.mediaPlay:
        if (!_controller.value.isPlaying) {
          _controller.play();
          _startHideControlsTimer();
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.mediaPause:
        if (_controller.value.isPlaying) {
          _controller.pause();
          setState(() => _showControls = true);
          _hideControlsTimer?.cancel();
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.mediaStop:
        _controller.pause();
        _controller.seekTo(Duration.zero);
        Navigator.of(context).pop();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.mediaRewind:
        _seekBackward(_longSeekSeconds);
        return KeyEventResult.handled;

      case LogicalKeyboardKey.mediaFastForward:
        _seekForward(_longSeekSeconds);
        return KeyEventResult.handled;

      default:
        // Mostrar controles para qualquer outra tecla
        _showControlsTemporarily();
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _playerFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Vídeo
              if (_isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              else if (_hasError)
                _buildErrorWidget()
              else
                _buildLoadingWidget(),

              // Indicador de buffering
              if (_isBuffering && _isInitialized)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),

              // Controles
              if (_showControls && _isInitialized)
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Carregando ${widget.title}...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Erro ao reproduzir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Erro desconhecido',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Tentar novamente',
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initializePlayer();
                  },
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.arrow_back,
                  label: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Barra superior com título
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildControlButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Controles centrais
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.replay_30,
                  size: 48,
                  onPressed: () => _seekBackward(_longSeekSeconds),
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.replay_10,
                  size: 56,
                  onPressed: () => _seekBackward(),
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 80,
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.forward_10,
                  size: 56,
                  onPressed: () => _seekForward(),
                ),
                const SizedBox(width: 24),
                _buildControlButton(
                  icon: Icons.forward_30,
                  size: 48,
                  onPressed: () => _seekForward(_longSeekSeconds),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Barra de progresso
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Tempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDuration(_controller.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Theme.of(context).colorScheme.primary,
                        bufferedColor: Colors.white.withOpacity(0.3),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Instruções
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHint(Icons.arrow_back, '10s'),
                      const SizedBox(width: 24),
                      _buildHint(Icons.radio_button_checked, 'Play/Pause'),
                      const SizedBox(width: 24),
                      _buildHint(Icons.arrow_forward, '10s'),
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

  Widget _buildControlButton({
    required IconData icon,
    double size = 40,
    VoidCallback? onPressed,
    String? label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          padding: EdgeInsets.all(size * 0.15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: size,
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHint(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
