import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'content_service.dart';

/// Serviço responsável por gerenciar a inicialização e coordenação entre outros serviços
class InitializationService {
  static AuthService? _authService;
  static ContentService? _contentService;
  
  /// Inicializa os serviços principais
  static void initialize(AuthService authService, ContentService contentService) {
    _authService = authService;
    _contentService = contentService;
    
    // Escuta mudanças no AuthService para reconfigurar o ContentService
    authService.addListener(_onAuthChanged);
  }
  
  /// Chamado quando há mudanças no estado de autenticação
  static void _onAuthChanged() {
    if (_authService?.isAuthenticated == true && _contentService != null) {
      debugPrint('🔄 AuthService mudou - limpando dados e recarregando para nova conta');
      
      // Limpar dados da conta anterior
      _contentService!.clearDataForAccountSwitch();
      
      // Aguardar um pouco para garantir que tudo está configurado
      Future.delayed(const Duration(milliseconds: 100), () {
        _configureContentService();
      });
    } else if (_authService?.isAuthenticated == false && _contentService != null) {
      debugPrint('🔄 Usuário deslogado - limpando dados');
      _contentService!.clearDataForAccountSwitch();
    }
  }
  
  /// Configura o ContentService baseado nas credenciais do AuthService
  static Future<void> _configureContentService() async {
    final credentials = _authService!.getStoredCredentials();
    final authMethod = credentials['authMethod'] as AuthMethod;
    
    debugPrint('🔧 Configurando ContentService para método: $authMethod');
    
    // Primeiro, carregar cache específico da conta
    await _contentService!.init();
    
    switch (authMethod) {
      case AuthMethod.xtream:
        _contentService!.initializeXtream(
          credentials['serverUrl'] as String,
          credentials['username'] as String,
          credentials['password'] as String,
        );
        
        // Carregar conteúdo automaticamente se não houver dados em cache
        if (!_contentService!.hasData) {
          debugPrint('� Sem cache, carregando dados do servidor Xtream...');
          try {
            // Carregar todos os tipos de conteúdo em paralelo
            await Future.wait([
              _contentService!.loadLiveChannels(),
              _contentService!.loadMovies(),
              _contentService!.loadSeries(),
            ]);
            debugPrint('✅ Conteúdo carregado automaticamente com sucesso');
          } catch (e) {
            debugPrint('❌ Erro ao carregar conteúdo automaticamente: $e');
          }
        } else {
          debugPrint('📦 Usando dados do cache para esta conta');
        }
        break;
        
      case AuthMethod.m3uUrl:
      case AuthMethod.m3uFile:
        _contentService!.initializeM3U();
        
        // Se não há dados em cache, carregar do M3U
        if (!_contentService!.hasData) {
          debugPrint('📥 Sem cache, carregando dados do M3U...');
          try {
            if (authMethod == AuthMethod.m3uUrl) {
              await _contentService!.loadM3UFromUrl(credentials['serverUrl'] as String);
            } else {
              await _contentService!.loadM3UFromFile(credentials['serverUrl'] as String);
            }
            debugPrint('✅ Conteúdo M3U carregado com sucesso');
          } catch (e) {
            debugPrint('❌ Erro ao carregar conteúdo M3U: $e');
          }
        } else {
          debugPrint('📦 Usando dados do cache M3U para esta conta');
        }
        break;
    }
  }
  
  /// Testa a conexão com as credenciais atuais
  static Future<bool> testCurrentConnection() async {
    if (_authService?.isAuthenticated != true || _contentService == null) {
      return false;
    }
    
    final credentials = _authService!.getStoredCredentials();
    final authMethod = credentials['authMethod'] as AuthMethod;
    
    try {
      switch (authMethod) {
        case AuthMethod.xtream:
          _configureContentService();
          return await _contentService!.testConnection();
        case AuthMethod.m3uUrl:
          await _contentService!.loadM3UFromUrl(credentials['serverUrl'] as String);
          return _contentService!.hasData;
        case AuthMethod.m3uFile:
          await _contentService!.loadM3UFromFile(credentials['serverUrl'] as String);
          return _contentService!.hasData;
      }
    } catch (e) {
      debugPrint('Erro ao testar conexão: $e');
      return false;
    }
  }
  
  /// Limpa os serviços (usado no logout)
  static void cleanup() {
    _authService?.removeListener(_onAuthChanged);
    _authService = null;
    _contentService = null;
  }
}
