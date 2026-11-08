import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/content_service.dart';
import 'services/download_service.dart';
import 'services/layout_service.dart';
import 'services/player_settings_service.dart';
import 'services/favorites_service.dart';
import 'services/epg_service.dart';
import 'services/category_service.dart';
import 'services/account_manager_service.dart';
import 'services/wakelock_service.dart';
import 'services/tv_detection_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tv_login_screen.dart';
import 'screens/tv_home_screen.dart';

void main() async {
  // Garante inicialização segura
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configura orientações permitidas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Configurações para iOS
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const TarTVApp());
}

class TarTVApp extends StatelessWidget {
  const TarTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Serviços básicos primeiro (sem inicialização síncrona)
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => PlayerSettingsService()),
        ChangeNotifierProvider(create: (_) => WakelockService()),
        
        // Serviço de detecção de TV
        ChangeNotifierProvider(
          create: (_) {
            final service = TvDetectionService();
            Future.microtask(() => service.init());
            return service;
          },
        ),
        
        // Serviços que precisam de inicialização assíncrona
        ChangeNotifierProvider(
          create: (_) {
            final service = AccountManagerService();
            // Inicializa assincronamente para evitar bloqueio
            Future.microtask(() => service.init());
            return service;
          },
        ),
        
        ChangeNotifierProxyProvider<AccountManagerService, AuthService>(
          create: (_) => AuthService(),
          update: (_, accountManager, authService) {
            authService ??= AuthService();
            authService.setAccountManager(accountManager);
            return authService;
          },
        ),
        
        ChangeNotifierProxyProvider<AuthService, ContentService>(
          create: (_) {
            final service = ContentService();
            Future.microtask(() => service.init());
            return service;
          },
          update: (_, authService, contentService) {
            contentService ??= ContentService();
            contentService.setAuthService(authService);
            return contentService;
          },
        ),
        
        ChangeNotifierProxyProvider<AuthService, DownloadService>(
          create: (_) {
            final service = DownloadService();
            Future.microtask(() => service.init());
            return service;
          },
          update: (_, authService, downloadService) {
            downloadService ??= DownloadService();
            downloadService.setAuthService(authService);
            return downloadService;
          },
        ),
        
        ChangeNotifierProvider(
          create: (_) {
            final service = LayoutService();
            Future.microtask(() => service.init());
            return service;
          },
        ),
        
        ChangeNotifierProvider(
          create: (_) {
            final service = FavoritesService();
            Future.microtask(() => service.init());
            return service;
          },
        ),
        
        ChangeNotifierProvider(create: (_) => EPGService()),
        
        ChangeNotifierProvider(
          create: (_) {
            final service = CategoryService();
            Future.microtask(() => service.init());
            return service;
          },
        ),
      ],
      child: Consumer4<AuthService, ThemeService, ContentService, TvDetectionService>(
        builder: (context, authService, themeService, contentService, tvService, child) {
          return MaterialApp(
            title: 'TarTV',
            debugShowCheckedModeBanner: false,
            theme: themeService.themeData,
            home: const SplashScreen(), // Sempre inicia com splash
            routes: {
              '/login': (context) => tvService.isAndroidTV 
                  ? const TvLoginScreen() 
                  : const LoginScreen(),
              '/home': (context) => tvService.isAndroidTV 
                  ? const TvHomeScreen() 
                  : const HomeScreen(),
              '/tv-login': (context) => const TvLoginScreen(),
              '/tv-home': (context) => const TvHomeScreen(),
            },
            // Error handling para prevenir crashes
            builder: (context, widget) {
              // Captura erros de renderização
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48),
                        SizedBox(height: 16),
                        Text('Erro ao carregar o app'),
                        Text('Reinicie o aplicativo'),
                      ],
                    ),
                  ),
                );
              };
              return widget ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
