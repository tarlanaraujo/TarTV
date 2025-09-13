# Quick Reference - TarTV

Referência rápida para desenvolvedores do TarTV IPTV.

## Comandos Essenciais

### Desenvolvimento

```bash
# Instalar dependências
flutter pub get

# Executar em debug
flutter run

# Executar no web
flutter run -d chrome

# Hot reload (durante desenvolvimento)
# Pressione 'r' no terminal ou Ctrl+S no VS Code

# Hot restart (reset completo)
# Pressione 'R' no terminal
```

### Build e Deploy

```bash
# APK de debug
flutter build apk

# APK de release (produção)
flutter build apk --release

# App Bundle (recomendado para Play Store)
flutter build appbundle --release

# Web build
flutter build web --release
```

### Limpeza e Troubleshooting

```bash
# Limpeza completa
flutter clean && flutter pub get

# Limpeza Android específica
cd android && ./gradlew clean && cd ..

# Verificar problemas
flutter doctor

# Analisar código
flutter analyze

# Formatar código
flutter format .
```

## Estrutura Rápida

### Diretórios Principais

```
lib/
├── main.dart           # Entry point
├── models/             # Channel, Movie, Series, etc.
├── screens/            # UI screens
├── services/           # Business logic (Auth, Content, etc.)
└── widgets/            # Reusable components
```

### Services Principais

```dart
// Provider setup (main.dart)
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => ContentService()),
    ChangeNotifierProvider(create: (_) => FavoritesService()),
    ChangeNotifierProvider(create: (_) => DownloadService()),
  ],
  child: MaterialApp(...)
)
```

## Padrões de Código

### Provider Pattern

```dart
// Service
class ExampleService extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;
  
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}

// Widget
Consumer<ExampleService>(
  builder: (context, service, child) {
    if (service.loading) return CircularProgressIndicator();
    return YourWidget();
  },
)
```

### Navigation

```dart
// Push
Navigator.push(context, 
  MaterialPageRoute(builder: (_) => NewScreen()));

// Push replacement
Navigator.pushReplacement(context,
  MaterialPageRoute(builder: (_) => NewScreen()));

// Pop
Navigator.pop(context);

// Pop with data
Navigator.pop(context, resultData);
```

### Error Handling

```dart
try {
  await someOperation();
} catch (e) {
  debugPrint('❌ Erro: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e')),
  );
}
```

## Xtream Codes API

### Endpoints Base

```
Base URL: http://server/player_api.php
```

### Login e Info

```dart
// Login
GET /player_api.php?username=X&password=Y&action=get_live_categories

// Server info
GET /player_api.php?username=X&password=Y&action=get_server_info

// Account info  
GET /player_api.php?username=X&password=Y&action=get_account_info
```

### Content Lists

```dart
// Channels
GET /player_api.php?username=X&password=Y&action=get_live_streams

// Movies
GET /player_api.php?username=X&password=Y&action=get_vod_streams  

// Series
GET /player_api.php?username=X&password=Y&action=get_series

// Categories
GET /player_api.php?username=X&password=Y&action=get_live_categories
GET /player_api.php?username=X&password=Y&action=get_vod_categories
```

### Stream URLs

```dart
// TV Channel
http://server:port/live/username/password/stream_id.ts

// Movie
http://server:port/movie/username/password/stream_id.mkv

// Series Episode
http://server:port/series/username/password/stream_id.mkv
```

## M3U Processing

### M3U Format

```m3u
#EXTM3U
#EXTINF:-1 tvg-id="channel1" tvg-name="Channel 1" tvg-logo="logo.png" group-title="Entertainment",Channel 1 Name
http://server/channel1.m3u8
#EXTINF:-1 tvg-id="channel2" tvg-name="Channel 2" group-title="Sports",Channel 2 Name  
http://server/channel2.ts
```

### Parser Usage

```dart
final parser = M3UParserService();
final channels = await parser.parseM3UContent(m3uContent);

// Grouped by category
final grouped = parser.groupChannelsByCategory(channels);
```

## UI Patterns

### AppBar Padrão

```dart
AppBar(
  title: Text('Screen Title'),
  elevation: 0,
  backgroundColor: Color(0xFF1A1A2E),
  foregroundColor: Colors.white,
)
```

### Grid de Canais

```dart
GridView.builder(
  padding: EdgeInsets.all(8),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 16/9,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

### Loading States

```dart
// Shimmer loading
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)

// Simple loading
Center(child: CircularProgressIndicator())
```

### Error Display

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.error_outline, size: 64, color: Colors.red),
    SizedBox(height: 16),
    Text('Erro ao carregar conteúdo'),
    SizedBox(height: 8),
    ElevatedButton(
      onPressed: () => service.retry(),
      child: Text('Tentar Novamente'),
    ),
  ],
)
```

## Video Player

### Setup Básico

```dart
late VideoPlayerController _controller;

@override
void initState() {
  super.initState();
  _controller = VideoPlayerController.network(videoUrl)
    ..initialize().then((_) => setState(() {}));
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return _controller.value.isInitialized
    ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
    : Center(child: CircularProgressIndicator());
}
```

### Chewie Integration

```dart
ChewieController _chewieController = ChewieController(
  videoPlayerController: _videoController,
  aspectRatio: 16/9,
  autoPlay: true,
  looping: false,
  showControls: true,
  materialProgressColors: ChewieProgressColors(
    playedColor: Colors.red,
    handleColor: Colors.red,
    backgroundColor: Colors.grey,
    bufferedColor: Colors.lightGreen,
  ),
);

Widget build(BuildContext context) {
  return Chewie(controller: _chewieController);
}
```

## Debugging

### Print Patterns

```dart
debugPrint('🔄 Carregando dados...');
debugPrint('✅ Sucesso: ${data.length} items');
debugPrint('❌ Erro: $error');
debugPrint('📡 API Response: ${response.statusCode}');
debugPrint('💾 Cache salvando...');
debugPrint('🎬 Player iniciando: $videoUrl');
```

### Common Issues

```dart
// Provider not found
// Verify provider is registered in main.dart

// Widget not updating  
// Use Consumer or context.watch<Service>()

// Memory leaks
// Always dispose controllers in dispose()

// Network errors
// Check server URL and credentials
```

## Performance Tips

### Images

```dart
// Use CachedNetworkImage
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  memCacheWidth: 300, // Limit memory usage
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Lists

```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id), // For efficiency
      title: Text(items[index].name),
    );
  },
)
```

### State Management

```dart
// Specific consumers
Consumer<AuthService>(builder: (context, auth, _) => AuthWidget())

// Multiple listeners
Consumer2<AuthService, ContentService>(
  builder: (context, auth, content, _) => ComplexWidget()
)
```

## Testing

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceName', () {
    late ServiceName service;
    
    setUp(() {
      service = ServiceName();
    });
    
    test('should do something', () {
      // Given
      final input = 'test';
      
      // When  
      final result = service.doSomething(input);
      
      // Then
      expect(result, equals('expected'));
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('should render correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => MockService(),
          child: YourWidget(),
        ),
      ),
    );
    
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

## Deployment

### Android Signing

```bash
# Generate keystore
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Build signed APK
flutter build apk --release

# Build App Bundle  
flutter build appbundle --release
```

### Release Checklist

- [ ] Increment version in pubspec.yaml
- [ ] Update CHANGELOG.md
- [ ] Run tests: `flutter test`
- [ ] Run analysis: `flutter analyze`
- [ ] Build release APK
- [ ] Test on physical device
- [ ] Update documentation

Este guia oferece:
- ⚡ **Acesso Rápido**: Comandos e padrões mais usados
- 🎯 **Foco Prático**: Apenas o essencial para desenvolvimento
- 📋 **Checklists**: Para deploys e validações
- 🔧 **Troubleshooting**: Soluções para problemas comuns
