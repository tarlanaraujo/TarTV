# Troubleshooting Guide - TarTV

Guia completo de solução de problemas para o TarTV IPTV.

## Problemas de Desenvolvimento

### 1. Flutter Doctor Issues

**Problema**: `flutter doctor` mostra erros

**Soluções**:

```bash
# Android license issues
flutter doctor --android-licenses

# Missing Android SDK
# Instalar Android Studio e configurar SDK path

# VS Code not detected
# Instalar Flutter extension para VS Code

# Verificar variáveis de ambiente
echo $FLUTTER_ROOT  # Linux/Mac
echo %FLUTTER_ROOT% # Windows
```

### 2. Dependency Issues

**Problema**: Conflitos de dependências

**Soluções**:

```bash
# Limpeza completa
flutter clean
flutter pub get

# Resolver conflitos específicos
flutter pub deps
flutter pub upgrade

# Cache issues
flutter pub cache repair
```

**Problema**: Package não encontrado após adicionar no pubspec.yaml

**Soluções**:

```bash
# Verificar sintaxe do pubspec.yaml
flutter pub get

# Restart completo
flutter clean && flutter pub get
# Reiniciar IDE
```

### 3. Build Issues

**Problema**: Build falha no Android

**Soluções**:

```bash
# Limpeza Android específica
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get

# Verificar Java/Gradle versions
./gradlew --version

# Memory issues
export GRADLE_OPTS="-Xmx4g -Dorg.gradle.daemon=false"
```

**Problema**: Build falha no Web

**Soluções**:

```bash
# CORS issues (desenvolvimento)
flutter run -d chrome --web-renderer html --disable-web-security

# Production build
flutter build web --release --web-renderer html

# Clear web cache
flutter clean
rm -rf build/web
flutter build web
```

## Problemas de Provider

### 1. Provider Not Found

**Erro**: `ProviderNotFoundException`

**Causa**: Provider não registrado ou contexto incorreto

**Solução**:

```dart
// ❌ Erro comum
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    // Provider usado fora do MultiProvider
    final auth = context.read<AuthService>();
    return MaterialApp(...);
  }
}

// ✅ Solução
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(...),
    );
  }
}
```

### 2. Widget Not Updating

**Problema**: UI não atualiza quando estado muda

**Causas e Soluções**:

```dart
// ❌ context.read não escuta mudanças
final auth = context.read<AuthService>();

// ✅ Consumer escuta mudanças
Consumer<AuthService>(
  builder: (context, auth, child) {
    return Text(auth.user?.name ?? 'Not logged');
  },
)

// ✅ context.watch também funciona
final auth = context.watch<AuthService>();
```

### 3. Memory Leaks

**Problema**: Listeners não removidos

**Solução**:

```dart
class _ScreenState extends State<Screen> {
  late AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _authService.addListener(_onAuthChange);
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthChange); // ✅ Importante!
    super.dispose();
  }
  
  void _onAuthChange() {
    if (mounted) setState(() {});
  }
}
```

## Problemas de API

### 1. Xtream Codes Authentication

**Problema**: Login falha com credenciais corretas

**Diagnóstico**:

```dart
debugPrint('🔍 Testing URL: $serverUrl/player_api.php');
debugPrint('🔍 Username: $username');
debugPrint('🔍 Password: $password');

final response = await http.get(Uri.parse(
  '$serverUrl/player_api.php?username=$username&password=$password&action=get_account_info'
));

debugPrint('📡 Response Status: ${response.statusCode}');
debugPrint('📡 Response Body: ${response.body}');
```

**Soluções Comuns**:

```dart
// 1. URL format issues
String cleanUrl(String url) {
  url = url.trim();
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'http://$url';
  }
  if (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

// 2. Special characters in credentials
String encodeCredential(String credential) {
  return Uri.encodeComponent(credential);
}

// 3. Timeout issues
final client = http.Client();
try {
  final response = await client.get(uri).timeout(Duration(seconds: 30));
} finally {
  client.close();
}
```

### 2. M3U Parsing Issues

**Problema**: M3U não carrega canais

**Diagnóstico**:

```dart
debugPrint('📁 M3U Content Preview:');
debugPrint(m3uContent.substring(0, min(500, m3uContent.length)));

final lines = m3uContent.split('\n');
debugPrint('📊 Total lines: ${lines.length}');

final extinfLines = lines.where((line) => line.startsWith('#EXTINF:')).length;
debugPrint('📺 EXTINF lines: $extinfLines');
```

**Soluções**:

```dart
// 1. Encoding issues
String fixEncoding(String content) {
  // Convert from Latin-1 to UTF-8 if needed
  try {
    final bytes = latin1.encode(content);
    return utf8.decode(bytes, allowMalformed: true);
  } catch (e) {
    return content;
  }
}

// 2. Malformed M3U
bool validateM3U(String content) {
  if (!content.trim().startsWith('#EXTM3U')) {
    debugPrint('❌ Missing #EXTM3U header');
    return false;
  }
  
  final lines = content.split('\n');
  final extinf = lines.where((l) => l.startsWith('#EXTINF:')).length;
  final urls = lines.where((l) => l.startsWith('http')).length;
  
  if (extinf != urls) {
    debugPrint('❌ Mismatched EXTINF and URLs: $extinf vs $urls');
    return false;
  }
  
  return true;
}
```

## Problemas de Video Player

### 1. Video Não Reproduz

**Diagnósticos**:

```dart
// Check video URL accessibility
Future<bool> testVideoUrl(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    debugPrint('🎬 Video URL test: ${response.statusCode}');
    debugPrint('🎬 Content-Type: ${response.headers['content-type']}');
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('❌ Video URL error: $e');
    return false;
  }
}

// Video player initialization
void initPlayer(String url) {
  _controller = VideoPlayerController.network(
    url,
    httpHeaders: {
      'User-Agent': 'TarTV/1.0',
      'Referer': serverUrl,
    },
  );
  
  _controller.addListener(() {
    if (_controller.value.hasError) {
      debugPrint('❌ Player error: ${_controller.value.errorDescription}');
    }
    
    debugPrint('🎬 Player state: ${_controller.value}');
  });
}
```

**Soluções Comuns**:

```dart
// 1. CORS issues (web)
VideoPlayerController.network(
  url,
  httpHeaders: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  },
)

// 2. User-Agent requirements
VideoPlayerController.network(
  url,
  httpHeaders: {
    'User-Agent': 'Mozilla/5.0 (compatible; TarTV)',
  },
)

// 3. Authentication headers
VideoPlayerController.network(
  url,
  httpHeaders: {
    'Authorization': 'Bearer $token',
    'X-Forwarded-For': '127.0.0.1',
  },
)
```

### 2. Performance Issues

**Problema**: Player lento ou trava

**Soluções**:

```dart
// 1. Buffer configuration
VideoPlayerController.network(
  url,
  videoPlayerOptions: VideoPlayerOptions(
    mixWithOthers: false,
    allowBackgroundPlayback: false,
  ),
)

// 2. Format selection
String getOptimalUrl(Map<String, String> qualities) {
  // Priority: 720p -> 480p -> 360p -> original
  return qualities['720p'] ?? 
         qualities['480p'] ?? 
         qualities['360p'] ?? 
         qualities.values.first;
}

// 3. Preload optimization  
@override
void initState() {
  super.initState();
  _preloadVideo();
}

Future<void> _preloadVideo() async {
  _controller = VideoPlayerController.network(videoUrl);
  await _controller.initialize();
  if (mounted) setState(() {});
}
```

## Problemas de Performance

### 1. App Lento

**Diagnóstico**:

```dart
// Memory usage tracking
void trackMemory() {
  final info = ProcessInfo.currentRss;
  debugPrint('💾 Memory usage: ${info / 1024 / 1024}MB');
}

// Widget rebuild tracking
class DebugConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext, T, Widget?) builder;
  
  const DebugConsumer({required this.builder});
  
  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 Rebuilding ${T.toString()}');
    return Consumer<T>(builder: builder);
  }
}
```

**Soluções**:

```dart
// 1. Optimize rebuilds
Consumer<AuthService>(
  builder: (context, auth, child) {
    return Column(
      children: [
        child!, // Cached widget
        Text(auth.user?.name ?? ''),
      ],
    );
  },
  child: const ExpensiveWidget(), // Won't rebuild
)

// 2. Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    if (index >= items.length - 5) {
      // Load more when near end
      context.read<ContentService>().loadMore();
    }
    return ItemWidget(items[index]);
  },
)

// 3. Image optimization
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 300, // Limit memory
  memCacheHeight: 200,
  maxWidthDiskCache: 300,
  maxHeightDiskCache: 200,
)
```

### 2. Network Issues

**Problema**: Requests lentos ou falham

**Soluções**:

```dart
// 1. Connection pooling
class ApiClient {
  static final _client = http.Client();
  
  static Future<http.Response> get(String url) {
    return _client.get(Uri.parse(url)).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Request timeout');
      },
    );
  }
}

// 2. Retry mechanism
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 1),
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      debugPrint('🔄 Retry ${i + 1}/$maxRetries: $e');
      await Future.delayed(delay);
    }
  }
  throw Exception('Max retries exceeded');
}

// 3. Cache implementation
class ApiCache {
  static final Map<String, CacheEntry> _cache = {};
  
  static Future<String> getCachedOrFetch(
    String url,
    Duration maxAge,
  ) async {
    final cached = _cache[url];
    if (cached != null && !cached.isExpired(maxAge)) {
      return cached.data;
    }
    
    final response = await http.get(Uri.parse(url));
    _cache[url] = CacheEntry(response.body, DateTime.now());
    return response.body;
  }
}
```

## Problemas de UI

### 1. Layout Issues

**Problema**: Overflow ou widgets mal posicionados

**Diagnóstico**:

```dart
// Debug layout
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.red), // Debug border
  ),
  child: YourWidget(),
)

// Check constraints
LayoutBuilder(
  builder: (context, constraints) {
    debugPrint('📐 Available: ${constraints.maxWidth}x${constraints.maxHeight}');
    return YourWidget();
  },
)
```

**Soluções**:

```dart
// 1. Overflow solutions
Flexible(child: Text('Long text that might overflow'))
Expanded(child: YourWidget())
SingleChildScrollView(child: Column(children: [...]))

// 2. Responsive design
Widget buildResponsive(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  
  if (width > 1200) {
    return DesktopLayout();
  } else if (width > 600) {
    return TabletLayout();
  } else {
    return MobileLayout();
  }
}

// 3. SafeArea usage
SafeArea(
  child: Scaffold(
    body: YourContent(),
  ),
)
```

### 2. Navigation Issues

**Problema**: Navigation não funciona ou app trava

**Soluções**:

```dart
// 1. Async navigation
void navigateAsync() async {
  final result = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => NewScreen()),
  );
  if (result != null) {
    // Handle result
  }
}

// 2. Navigation guards
bool canNavigate() {
  if (!context.read<AuthService>().isAuthenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login required')),
    );
    return false;
  }
  return true;
}

// 3. Named routes (para apps complexos)
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/login': (context) => LoginScreen(),
    '/player': (context) => PlayerScreen(),
  },
  onUnknownRoute: (settings) {
    return MaterialPageRoute(
      builder: (_) => NotFoundScreen(),
    );
  },
)
```

## Logs e Debugging

### Debug Eficiente

```dart
// Structured logging
class Logger {
  static void info(String message) {
    debugPrint('ℹ️ INFO: $message');
  }
  
  static void error(String message, [Object? error, StackTrace? stack]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('Details: $error');
    if (stack != null) debugPrint('Stack: $stack');
  }
  
  static void api(String method, String url, int statusCode) {
    debugPrint('📡 API: $method $url -> $statusCode');
  }
}

// Conditional debugging
void debugLog(String message) {
  if (kDebugMode) {
    debugPrint('🐛 DEBUG: $message');
  }
}

// Performance monitoring
T timeOperation<T>(String name, T Function() operation) {
  final stopwatch = Stopwatch()..start();
  try {
    final result = operation();
    debugPrint('⏱️ $name took ${stopwatch.elapsedMilliseconds}ms');
    return result;
  } finally {
    stopwatch.stop();
  }
}
```

### Remote Debugging

```dart
// Crash reporting (Firebase Crashlytics example)
void setupCrashReporting() {
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exception}');
    // FirebaseCrashlytics.instance.recordFlutterError(details);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    // FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
}

// Analytics tracking
void trackEvent(String event, Map<String, dynamic> parameters) {
  debugPrint('📊 Event: $event - $parameters');
  // FirebaseAnalytics.instance.logEvent(name: event, parameters: parameters);
}
```

## Checklist de Troubleshooting

### Quando algo não funciona:

1. **🔍 Gather Information**
   - [ ] Reproduzir o problema consistentemente
   - [ ] Verificar logs de erro
   - [ ] Testar em diferentes dispositivos/plataformas
   - [ ] Verificar versão do Flutter/Dart

2. **🧪 Isolate the Problem**
   - [ ] Minimal reproduction case
   - [ ] Test individual components
   - [ ] Check recent changes in git

3. **🔧 Apply Solutions**
   - [ ] Try common solutions first
   - [ ] Check documentation/GitHub issues
   - [ ] Test fix thoroughly
   - [ ] Update tests if needed

4. **📚 Document Solution**
   - [ ] Add comments in code
   - [ ] Update troubleshooting guide
   - [ ] Share with team

### Performance Checklist:

1. **🏃‍♂️ Runtime Performance**
   - [ ] Use `flutter run --profile` para análise
   - [ ] Check widget rebuilds
   - [ ] Optimize expensive operations
   - [ ] Implement pagination/lazy loading

2. **💾 Memory Management**
   - [ ] Dispose controllers properly
   - [ ] Remove listeners
   - [ ] Optimize image sizes
   - [ ] Clear caches when needed

3. **📡 Network Optimization**
   - [ ] Implement retry logic
   - [ ] Cache responses
   - [ ] Compress images
   - [ ] Use connection pooling

Este guia garante:
- 🚨 **Resolução Rápida**: Soluções para problemas mais comuns
- 🔍 **Diagnóstico Eficiente**: Ferramentas e métodos de debug
- 📋 **Checklists Práticos**: Procedimentos sistemáticos
- 🛡️ **Prevenção**: Boas práticas para evitar problemas
