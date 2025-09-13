import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'account_manager_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _serverUrl;
  String? _username;
  String? _password;
  AuthMethod _authMethod = AuthMethod.xtream;
  AccountManagerService? _accountManager;
  String? _m3uContent; // Conteúdo do arquivo M3U carregado
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoggedIn => _isAuthenticated; // Alias para compatibilidade
  String? get serverUrl => _serverUrl;
  String? get username => _username;
  String? get password => _password; // Getter público para password
  AuthMethod get authMethod => _authMethod;
  String? get m3uContent => _m3uContent; // Getter para conteúdo M3U
  
  // Getter para compatibilidade - retorna um objeto com dados do usuário
  Map<String, String?>? get currentUser => _isAuthenticated ? {
    'username': _username,
    'serverUrl': _serverUrl,
  } : null;
  
  void setAccountManager(AccountManagerService accountManager) {
    _accountManager = accountManager;
  }
  
  AuthService() {
    _loadSavedCredentials();
  }
  
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _serverUrl = prefs.getString('serverUrl');
    _username = prefs.getString('username');
    _password = prefs.getString('password');
    final methodIndex = prefs.getInt('authMethod') ?? 0;
    _authMethod = AuthMethod.values[methodIndex];
    
    // Validate credentials - if any required field is missing, clear auth
    if (_isAuthenticated) {
      bool validCredentials = false;
      
      switch (_authMethod) {
        case AuthMethod.xtream:
          validCredentials = _serverUrl?.isNotEmpty == true && 
                           _username?.isNotEmpty == true && 
                           _password?.isNotEmpty == true;
          break;
        case AuthMethod.m3uUrl:
        case AuthMethod.m3uFile:
          validCredentials = _serverUrl?.isNotEmpty == true;
          break;
      }
      
      if (!validCredentials) {
        debugPrint('Invalid stored credentials, clearing auth state');
        _isAuthenticated = false;
        _serverUrl = null;
        _username = null;
        _password = null;
        await prefs.clear();
      }
    }
    
    // Use WidgetsBinding to ensure we're not in the middle of a build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  Future<bool> loginXtream(String serverUrl, String username, String password) async {
    try {
      _authMethod = AuthMethod.xtream;
      
      // Validação básica de URL
      if (!_isValidUrl(serverUrl)) {
        return false;
      }
      
      _serverUrl = serverUrl;
      _username = username;
      _password = password;
      _isAuthenticated = true;
      
      // Salvar credenciais
      await _saveCredentials();
      
      // Salvar conta no gerenciador
      await saveCurrentAccountToManager();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro no login Xtream: $e');
      return false;
    }
  }
  
  Future<bool> loginM3UUrl(String url) async {
    try {
      _authMethod = AuthMethod.m3uUrl;
      
      // Validação básica de URL
      if (!_isValidUrl(url)) {
        return false;
      }
      
      _serverUrl = url;
      
      // Para M3U URL, extrair informações úteis da URL
      try {
        final uri = Uri.parse(url);
        _username = uri.host; // Host como "usuário" para identificação
        _password = 'M3U Link'; // Identificador do tipo
      } catch (e) {
        _username = 'M3U Link';
        _password = 'URL';
      }
      
      _isAuthenticated = true;
      
      await _saveCredentials();
      await saveCurrentAccountToManager();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro no login M3U URL: $e');
      return false;
    }
  }
  
  Future<bool> loginM3UFile(String filePath) async {
    try {
      _authMethod = AuthMethod.m3uFile;
      
      // Validação básica do caminho
      if (filePath.isEmpty) {
        return false;
      }
      
      // Processar conteúdo do arquivo M3U
      final m3uContent = await _loadM3UFile(filePath);
      if (m3uContent == null || m3uContent.isEmpty) {
        debugPrint('Erro: Arquivo M3U vazio ou inválido');
        return false;
      }
      
      // Para M3U File, extrair informações úteis do caminho
      _serverUrl = filePath;
      
      try {
        final fileName = filePath.split('/').last.split('\\').last;
        _username = fileName.replaceAll('.m3u', '').replaceAll('.M3U', '');
        _password = 'Arquivo M3U';
      } catch (e) {
        _username = 'Arquivo M3U';
        _password = 'Local';
      }
      
      _isAuthenticated = true;
      _m3uContent = m3uContent;
      
      await _saveCredentials();
      await saveCurrentAccountToManager();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro no login M3U File: $e');
      return false;
    }
  }
  
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('serverUrl', _serverUrl ?? '');
    await prefs.setString('username', _username ?? '');
    await prefs.setString('password', _password ?? '');
    await prefs.setInt('authMethod', _authMethod.index);
  }
  
  Future<void> logout() async {
    _isAuthenticated = false;
    _serverUrl = null;
    _username = null;
    _password = null;
    _authMethod = AuthMethod.xtream;
    
    // Limpar credenciais salvas
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
  
  /// Método genérico para login (backward compatibility)
  Future<bool> login(String serverUrl, String username, String password) async {
    return await loginXtream(serverUrl, username, password);
  }
  
  /// Obtém as credenciais salvas para reconfigurar o ContentService
  Map<String, dynamic> getStoredCredentials() {
    return {
      'serverUrl': _serverUrl,
      'username': _username,
      'password': _password,
      'authMethod': _authMethod,
    };
  }

  /// Valida se uma URL é válida
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // Métodos de integração com AccountManager
  Future<bool> loginFromAccount(AccountData account) async {
    try {
      _serverUrl = account.serverUrl;
      _username = account.username;
      _password = account.password;
      _authMethod = account.isXtream ? AuthMethod.xtream : AuthMethod.m3uUrl;
      _isAuthenticated = true;
      
      await _saveCredentials();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao fazer login da conta: $e');
      return false;
    }
  }
  
  Future<void> saveCurrentAccountToManager() async {
    if (_accountManager != null && _isAuthenticated && 
        _serverUrl != null && _username != null && _password != null) {
      
      final accountId = _accountManager!.generateAccountId(_serverUrl!, _username!);
      final accountName = _accountManager!.generateAccountName(_serverUrl!, _username!);
      
      final account = AccountData(
        id: accountId,
        name: accountName,
        serverUrl: _serverUrl!,
        username: _username!,
        password: _password!,
        lastUsed: DateTime.now(),
        isXtream: _authMethod == AuthMethod.xtream,
      );
      
      await _accountManager!.addAccount(account);
    }
  }
  
  Future<bool> switchAccount(String accountId) async {
    if (_accountManager != null) {
      await _accountManager!.switchToAccount(accountId);
      final account = _accountManager!.currentAccount;
      
      if (account != null) {
        return await loginFromAccount(account);
      }
    }
    return false;
  }
  
  /// Carrega e processa um arquivo M3U local
  Future<String?> _loadM3UFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        debugPrint('Arquivo M3U não encontrado: $filePath');
        return null;
      }
      
      final content = await file.readAsString();
      
      // Validação básica do formato M3U
      if (!content.startsWith('#EXTM3U')) {
        debugPrint('Arquivo não é um M3U válido (não inicia com #EXTM3U)');
        return null;
      }
      
      return content;
    } catch (e) {
      debugPrint('Erro ao carregar arquivo M3U: $e');
      return null;
    }
  }
}

enum AuthMethod {
  xtream,
  m3uUrl,
  m3uFile,
}
