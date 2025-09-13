import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/content_service.dart';
import 'services/initialization_service.dart';
import 'services/download_service.dart';
import 'services/layout_service.dart';
import 'services/player_settings_service.dart';
import 'services/favorites_service.dart';
import 'services/epg_service.dart';
import 'services/category_service.dart';
import 'services/account_manager_service.dart';
import 'services/wakelock_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TarTVApp());
}

class TarTVApp extends StatelessWidget {
  const TarTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountManagerService()..init()),
        ChangeNotifierProxyProvider<AccountManagerService, AuthService>(
          create: (_) => AuthService(),
          update: (_, accountManager, authService) {
            authService!.setAccountManager(accountManager);
            return authService;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProxyProvider<AuthService, ContentService>(
          create: (_) => ContentService()..init(),
          update: (_, authService, contentService) {
            contentService!.setAuthService(authService);
            return contentService;
          },
        ),
        ChangeNotifierProxyProvider<AuthService, DownloadService>(
          create: (_) => DownloadService()..init(),
          update: (_, authService, downloadService) {
            downloadService!.setAuthService(authService);
            return downloadService;
          },
        ),
        ChangeNotifierProvider(create: (_) => LayoutService()..init()),
        ChangeNotifierProvider(create: (_) => PlayerSettingsService()),
        ChangeNotifierProvider(create: (_) => WakelockService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()..init()),
        ChangeNotifierProvider(create: (_) => EPGService()),
        ChangeNotifierProvider(create: (_) => CategoryService()..init()),
      ],
      child: Consumer3<AuthService, ThemeService, ContentService>(
        builder: (context, authService, themeService, contentService, child) {
          // Inicializa os serviços quando disponíveis
          WidgetsBinding.instance.addPostFrameCallback((_) {
            InitializationService.initialize(authService, contentService);
          });
          
          return MaterialApp(
            title: 'TarTV',
            debugShowCheckedModeBanner: false,
            theme: themeService.themeData,
            home: authService.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
