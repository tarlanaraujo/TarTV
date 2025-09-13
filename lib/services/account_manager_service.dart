import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccountData {
  final String id;
  final String name;
  final String serverUrl;
  final String username;
  final String password;
  final String? logoUrl;
  final DateTime lastUsed;
  final bool isXtream;

  AccountData({
    required this.id,
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.logoUrl,
    required this.lastUsed,
    required this.isXtream,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'logoUrl': logoUrl,
      'lastUsed': lastUsed.toIso8601String(),
      'isXtream': isXtream,
    };
  }

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      id: json['id'],
      name: json['name'],
      serverUrl: json['serverUrl'],
      username: json['username'],
      password: json['password'],
      logoUrl: json['logoUrl'],
      lastUsed: DateTime.parse(json['lastUsed']),
      isXtream: json['isXtream'] ?? true,
    );
  }

  AccountData copyWith({
    String? name,
    String? logoUrl,
    DateTime? lastUsed,
  }) {
    return AccountData(
      id: id,
      name: name ?? this.name,
      serverUrl: serverUrl,
      username: username,
      password: password,
      logoUrl: logoUrl ?? this.logoUrl,
      lastUsed: lastUsed ?? this.lastUsed,
      isXtream: isXtream,
    );
  }
}

class AccountManagerService extends ChangeNotifier {
  static const String _accountsKey = 'saved_accounts';
  static const String _currentAccountKey = 'current_account_id';
  
  List<AccountData> _accounts = [];
  AccountData? _currentAccount;
  
  List<AccountData> get accounts => List.unmodifiable(_accounts);
  AccountData? get currentAccount => _currentAccount;
  bool get hasMultipleAccounts => _accounts.length > 1;
  
  Future<void> init() async {
    await loadAccounts();
  }
  
  Future<void> loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = prefs.getString(_accountsKey);
      final currentAccountId = prefs.getString(_currentAccountKey);
      
      if (accountsJson != null) {
        final List<dynamic> accountsList = jsonDecode(accountsJson);
        _accounts = accountsList.map((json) => AccountData.fromJson(json)).toList();
        
        // Ordenar por último uso
        _accounts.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        
        // Definir conta atual
        if (currentAccountId != null) {
          try {
            _currentAccount = _accounts.firstWhere(
              (account) => account.id == currentAccountId,
            );
          } catch (e) {
            _currentAccount = _accounts.isNotEmpty ? _accounts.first : null;
          }
        } else if (_accounts.isNotEmpty) {
          _currentAccount = _accounts.first;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar contas: $e');
    }
  }
  
  Future<void> saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsJson = jsonEncode(_accounts.map((account) => account.toJson()).toList());
      
      await prefs.setString(_accountsKey, accountsJson);
      
      if (_currentAccount != null) {
        await prefs.setString(_currentAccountKey, _currentAccount!.id);
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar contas: $e');
    }
  }
  
  Future<void> addAccount(AccountData account) async {
    // Verificar se já existe uma conta com os mesmos dados
    AccountData? existing;
    try {
      existing = _accounts.firstWhere(
        (acc) => acc.serverUrl == account.serverUrl && acc.username == account.username,
      );
    } catch (e) {
      existing = null;
    }
    
    if (existing != null) {
      // Atualizar conta existente
      final index = _accounts.indexOf(existing);
      _accounts[index] = existing.copyWith(
        name: account.name,
        lastUsed: DateTime.now(),
      );
    } else {
      // Adicionar nova conta
      _accounts.add(account.copyWith(lastUsed: DateTime.now()));
    }
    
    await saveAccounts();
    notifyListeners();
  }
  
  Future<void> switchToAccount(String accountId) async {
    AccountData? account;
    try {
      account = _accounts.firstWhere(
        (acc) => acc.id == accountId,
      );
    } catch (e) {
      account = null;
    }
    
    if (account != null) {
      _currentAccount = account.copyWith(lastUsed: DateTime.now());
      
      // Atualizar última vez usada
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index >= 0) {
        _accounts[index] = _currentAccount!;
      }
      
      await saveAccounts();
      notifyListeners();
    }
  }
  
  Future<void> removeAccount(String accountId) async {
    _accounts.removeWhere((acc) => acc.id == accountId);
    
    if (_currentAccount?.id == accountId) {
      _currentAccount = _accounts.isNotEmpty ? _accounts.first : null;
    }
    
    await saveAccounts();
    notifyListeners();
  }
  
  Future<void> updateAccountName(String accountId, String newName) async {
    final index = _accounts.indexWhere((acc) => acc.id == accountId);
    if (index >= 0) {
      _accounts[index] = _accounts[index].copyWith(name: newName);
      
      if (_currentAccount?.id == accountId) {
        _currentAccount = _accounts[index];
      }
      
      await saveAccounts();
      notifyListeners();
    }
  }
  
  String generateAccountId(String serverUrl, String username) {
    return '${serverUrl}_$username'.hashCode.toString();
  }
  
  String generateAccountName(String serverUrl, String username) {
    try {
      final uri = Uri.parse(serverUrl);
      final domain = uri.host;
      return '$username@$domain';
    } catch (e) {
      return '$username@$serverUrl';
    }
  }
  
  Future<void> clearAllAccounts() async {
    _accounts.clear();
    _currentAccount = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
    await prefs.remove(_currentAccountKey);
    
    notifyListeners();
  }
}
