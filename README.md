# TarTV - Aplicativo IPTV Flutter

Um aplicativo completo de IPTV desenvolvido em Flutter, com suporte nativo para Xtream Codes, listas M3U/M3U8 e player de vídeo robusto.

## 🎯 Características Principais

- **Login Xtream Codes**: Autenticação completa com servidor, usuário e senha
- **Suporte M3U**: Importação via URL ou arquivo local
- **Player Nativo**: Reprodução sem bloqueios de CORS
- **TV Ao Vivo**: Canais organizados por categoria
- **Filmes e Séries**: VOD completo com navegação intuitiva
- **Interface Moderna**: Design limpo e responsivo

## 📱 Funcionalidades

### ✅ Implementado
- [x] Tela de login com múltiplas opções
- [x] Autenticação Xtream Codes
- [x] Estrutura de navegação principal
- [x] Modelos de dados para canais, filmes e séries
- [x] Serviço completo de API Xtream
- [x] Configuração Android otimizada

### 🚧 Em Desenvolvimento
- [ ] Interface de TV ao vivo
- [ ] Player de vídeo integrado
- [ ] Importador M3U
- [ ] Sistema de busca
- [ ] Downloads offline
- [ ] EPG (Guia de programação)

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.1+**: Framework principal
- **Provider**: Gerenciamento de estado
- **HTTP/Dio**: Requisições de rede
- **Video Player**: Reprodução nativa
- **Shared Preferences**: Armazenamento local

## 📋 Pré-requisitos

1. **Flutter SDK**: Versão 3.1.0 ou superior
2. **Android Studio**: Para desenvolvimento Android
3. **VS Code**: Editor recomendado

## 🚀 Como Executar

### 1. Instalar Dependências
```bash
flutter pub get
```

### 2. Executar em Debug
```bash
flutter run
```

### 3. Gerar APK
```bash
flutter build apk --release
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada
├── models/                # Modelos de dados
│   └── media_models.dart  # Channel, Movie, Series, etc.
├── screens/               # Telas da aplicação
│   ├── login_screen.dart  # Login Xtream/M3U
│   └── home_screen.dart   # Navegação principal
└── services/              # Serviços e APIs
    ├── auth_service.dart  # Autenticação
    └── xtream_service.dart # API Xtream Codes
```

## 🔧 Configuração

### Permissões Android
O app inclui todas as permissões necessárias:
- Internet e rede
- Armazenamento externo
- Wake lock para reprodução

### Configuração de Rede
- Suporte a HTTP e HTTPS
- `usesCleartextTraffic="true"` para servidores HTTP

## 📖 Como Usar

1. **Primeiro Acesso**: Escolha o método de conexão
   - Xtream Codes: Servidor + Usuário + Senha
   - URL M3U: Link direto para playlist
   - Arquivo M3U: Upload de arquivo local

2. **Navegação**: Use as abas inferiores
   - TV Ao Vivo: Canais por categoria
   - Filmes: Catálogo de filmes
   - Séries: Séries com temporadas/episódios
   - Configurações: Conta e preferências

## 🎥 Player de Vídeo

O player nativo resolve os problemas de CORS encontrados em players web:
- Conexão direta com servidores
- Suporte completo a formatos IPTV
- Controles touch otimizados
- Tela cheia automática

## 🔐 Segurança

- Credenciais salvas localmente com SharedPreferences
- Conexões seguras HTTPS quando disponível
- Validação de entrada em todos os formulários

## 📝 Licença

Este projeto é de código aberto para fins educacionais e pessoais.

## 🤝 Contribuição

Sinta-se à vontade para contribuir com melhorias, correções ou novas funcionalidades!

---

**Desenvolvido com ❤️ em Flutter**
