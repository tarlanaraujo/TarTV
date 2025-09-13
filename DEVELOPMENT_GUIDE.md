# Development Guide - TarTV

Guia de desenvolvimento para contribuidores do projeto TarTV IPTV.

## Configuração do Ambiente

### Pré-requisitos

- **Flutter SDK**: 3.19.0 ou superior
- **Dart SDK**: 3.1.0 ou superior
- **Android Studio**: Para desenvolvimento Android
- **VS Code**: Recomendado para desenvolvimento Flutter
- **Git**: Para controle de versão

### Instalação

```bash
# Clonar o repositório
git clone <repository-url>
cd TarTV

# Instalar dependências
flutter pub get

# Verificar configuração
flutter doctor

# Executar em modo debug
flutter run
```

### Configuração do IDE

#### VS Code Extensions Recomendadas

- Flutter
- Dart
- Bracket Pair Colorizer
- GitLens
- Error Lens

#### Android Studio Plugins

- Flutter Plugin
- Dart Plugin

## Estrutura do Projeto

### Organização de Código

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
├── screens/                     # UI screens
├── services/                    # Business logic
├── widgets/                     # Reusable components
└── utils/                       # Utilities (if needed)
```

### Convenções de Nomenclatura

```dart
// Classes: PascalCase
class AuthService extends ChangeNotifier {}

// Methods e Variables: camelCase
void loadChannels() {}
bool _isLoading = false;

// Constants: UPPER_SNAKE_CASE
static const int DEFAULT_TIMEOUT = 30;

// Files: snake_case
auth_service.dart
movie_detail_screen.dart
```

## Padrões de Desenvolvimento

### 1. State Management com Provider

**Criar um novo Service:**

```dart
class NewService extends ChangeNotifier {
  // Estado privado
  List<Data> _data = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters públicos
  List<Data> get data => List.unmodifiable(_data);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Métodos públicos
  Future<void> loadData() async {
    _setLoading(true);
    try {
      _data = await _fetchData();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro em loadData: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helpers privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  Future<List<Data>> _fetchData() async {
    // Implementação da busca
  }
}
```

**Registrar no Provider:**

```dart
// main.dart
ChangeNotifierProvider(create: (_) => NewService()),
```

**Usar na UI:**

```dart
Consumer<NewService>(
  builder: (context, service, child) {
    if (service.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (service.error != null) {
      return ErrorWidget(service.error!);
    }
    
    return ListView.builder(
      itemCount: service.data.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(service.data[index].name));
      },
    );
  },
)
```

### 2. Modelos de Dados

**Estrutura padrão:**

```dart
class ExampleModel {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  
  const ExampleModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });
  
  // Factory constructor para JSON
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
  
  // Método para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  // CopyWith para imutabilidade (opcional)
  ExampleModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 3. Telas (Screens)

**Template básico:**

```dart
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Inicialização
  }

  @override
  void dispose() {
    // Limpeza de recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: Consumer<ExampleService>(
        builder: (context, service, child) {
          return _buildContent(service);
        },
      ),
    );
  }
  
  Widget _buildContent(ExampleService service) {
    // Construir conteúdo baseado no estado do service
    if (service.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView(
      children: service.items.map((item) => _buildItem(item)).toList(),
    );
  }
  
  Widget _buildItem(ExampleItem item) {
    return ListTile(
      title: Text(item.name),
      onTap: () => _onItemTap(item),
    );
  }
  
  void _onItemTap(ExampleItem item) {
    // Ação do tap
  }
}
```

## Testing

### Estrutura de Testes

```
test/
├── unit/
│   ├── models/
│   │   └── example_model_test.dart
│   └── services/
│       └── example_service_test.dart
├── widget/
│   └── screens/
│       └── example_screen_test.dart
└── integration/
    └── app_test.dart
```

### Testes Unitários

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tartv_app/models/example_model.dart';

void main() {
  group('ExampleModel', () {
    test('should create from JSON correctly', () {
      // Given
      final json = {
        'id': '123',
        'name': 'Test Name',
        'description': 'Test Description',
      };
      
      // When
      final model = ExampleModel.fromJson(json);
      
      // Then
      expect(model.id, '123');
      expect(model.name, 'Test Name');
      expect(model.description, 'Test Description');
    });
    
    test('should handle null values gracefully', () {
      // Given
      final json = <String, dynamic>{};
      
      // When
      final model = ExampleModel.fromJson(json);
      
      // Then
      expect(model.id, '');
      expect(model.name, '');
      expect(model.description, null);
    });
  });
}
```

### Testes de Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tartv_app/screens/example_screen.dart';
import 'package:tartv_app/services/example_service.dart';

void main() {
  group('ExampleScreen', () {
    late ExampleService mockService;
    
    setUp(() {
      mockService = MockExampleService();
    });
    
    testWidgets('should show loading indicator when loading', (tester) async {
      // Given
      when(mockService.isLoading).thenReturn(true);
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExampleService>.value(
            value: mockService,
            child: const ExampleScreen(),
          ),
        ),
      );
      
      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## Debugging

### Logs Estruturados

Use o padrão de emoji para logs:

```dart
debugPrint('🔄 Iniciando carregamento...');
debugPrint('✅ Carregamento concluído: ${items.length} items');
debugPrint('❌ Erro no carregamento: $error');
debugPrint('📡 Resposta da API: ${response.statusCode}');
debugPrint('💾 Salvando no cache...');
```

### Debug no VS Code

Configuração de launch.json:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Flutter",
      "request": "launch",
      "type": "dart",
      "args": ["--hot"]
    },
    {
      "name": "Debug Flutter Web",
      "request": "launch",
      "type": "dart",
      "args": ["--web-renderer", "html", "--hot"]
    }
  ]
}
```

## Performance

### Otimizações Implementadas

1. **Widget Rebuilds Otimizados**
```dart
// ✅ Bom - Consumer específico
Consumer<SpecificService>(
  builder: (context, service, child) => SpecificWidget(service.data),
)

// ❌ Ruim - Consumer genérico
Consumer<MultipleServices>(
  builder: (context, services, child) => WholeScreen(),
)
```

2. **Lista Performance**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ExampleTile(
      key: ValueKey(item.id), // Key para eficiência
      item: item,
    );
  },
)
```

3. **Image Optimization**
```dart
CachedNetworkImage(
  imageUrl: item.imageUrl,
  fit: BoxFit.cover,
  memCacheWidth: 300, // Limitar tamanho na memória
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

## Workflow de Desenvolvimento

### Git Flow

```bash
# Feature branch
git checkout -b feature/nova-funcionalidade
git add .
git commit -m "feat: adiciona nova funcionalidade"
git push origin feature/nova-funcionalidade

# Create Pull Request
# Após aprovação, merge para main
```

### Commit Messages

Seguir padrão Conventional Commits:

```
feat: adiciona sistema de download
fix: corrige erro de autenticação M3U
docs: atualiza documentação da API
refactor: refatora ContentService
test: adiciona testes para AuthService
```

### Code Review Checklist

- [ ] Código segue padrões estabelecidos
- [ ] Testes implementados/atualizados
- [ ] Documentação atualizada
- [ ] Performance considerada
- [ ] Tratamento de erros adequado
- [ ] UI responsiva
- [ ] Acessibilidade considerada

## Build e Deploy

### Desenvolvimento

```bash
# Debug build
flutter run

# Debug com web
flutter run -d chrome

# Profile mode (performance testing)
flutter run --profile
```

### Produção

```bash
# Release APK
flutter build apk --release

# Release App Bundle (recomendado)
flutter build appbundle --release

# Web build
flutter build web --release
```

### Configurações de Build

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt')
        }
    }
}
```

## Troubleshooting

### Problemas Comuns

1. **Provider not found**
```dart
// Solução: Verificar se Provider está registrado no main.dart
MaterialApp(
  home: MultiProvider(providers: [...], child: MyApp())
)
```

2. **Hot reload não funciona**
```bash
# Solução: Hot restart
flutter run --hot
# Ou tecla 'R' no terminal
```

3. **Build falha no Android**
```bash
# Limpeza completa
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk
```

### Debug de Performance

```bash
# Performance profiling
flutter run --profile
# Abrir DevTools para análise detalhada
```

## Contribuição

### Antes de Contribuir

1. Leia toda esta documentação
2. Configure ambiente de desenvolvimento
3. Execute testes existentes
4. Crie branch para sua feature

### Pull Request Process

1. Fork do repositório
2. Crie feature branch
3. Implemente mudanças
4. Adicione testes
5. Atualize documentação
6. Submeta PR com descrição detalhada

### Code Standards

- Seguir Dart/Flutter style guide
- Usar análise estática: `flutter analyze`
- Formatar código: `flutter format .`
- Comentar código complexo
- Manter cobertura de testes

Este guia garante:
- 🏗️ **Consistência**: Padrões unificados em todo projeto
- 🚀 **Produtividade**: Fluxo de desenvolvimento otimizado
- 🧪 **Qualidade**: Testes e validações em todas camadas
- 📚 **Manutenibilidade**: Documentação completa e atualizada
