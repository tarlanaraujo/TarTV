# API Documentation - TarTV IPTV

Esta documentação descreve as APIs e integrações utilizadas pelo aplicativo TarTV.

## Visão Geral

O TarTV suporta duas principais fontes de conteúdo IPTV:

1. **Xtream Codes API** - API padrão da indústria IPTV
2. **M3U Playlists** - Arquivos/URLs de playlist padrão

## Xtream Codes API

### Base URL
```
http://servidor.com:porta/player_api.php
```

### Autenticação

**Endpoint:** `GET /player_api.php`

**Parâmetros obrigatórios:**
- `username`: Nome de usuário
- `password`: Senha

**Exemplo:**
```http
GET /player_api.php?username=user&password=pass
```

**Resposta de sucesso:**
```json
{
  "user_info": {
    "username": "user",
    "password": "pass",
    "auth": 1,
    "status": "Active",
    "exp_date": "1672531200",
    "is_trial": "0",
    "active_cons": "1",
    "max_connections": "2"
  },
  "server_info": {
    "url": "http://servidor.com:porta",
    "port": "80",
    "protocol": "http",
    "timezone": "America/Sao_Paulo"
  }
}
```

### Endpoints Disponíveis

#### 1. Listar Canais ao Vivo

**Endpoint:** `GET /player_api.php?username={user}&password={pass}&action=get_live_streams`

**Resposta:**
```json
[
  {
    "num": 1,
    "name": "Canal Example",
    "stream_type": "live",
    "stream_id": "12345",
    "stream_icon": "http://exemplo.com/logo.png",
    "epg_channel_id": "canal.exemplo",
    "added": "1609459200",
    "category_id": "1",
    "tv_archive": 0,
    "direct_source": "",
    "tv_archive_duration": 0
  }
]
```

#### 2. Listar Filmes

**Endpoint:** `GET /player_api.php?username={user}&password={pass}&action=get_vod_streams`

**Resposta:**
```json
[
  {
    "num": 1,
    "name": "Filme Example",
    "stream_type": "movie",
    "stream_id": "67890",
    "stream_icon": "http://exemplo.com/poster.jpg",
    "rating": "8.5",
    "added": "1609459200",
    "category_id": "2",
    "container_extension": "mp4",
    "direct_source": ""
  }
]
```

#### 3. Listar Séries

**Endpoint:** `GET /player_api.php?username={user}&password={pass}&action=get_series`

**Resposta:**
```json
[
  {
    "num": 1,
    "name": "Série Example",
    "stream_type": "series",
    "series_id": "11111",
    "cover": "http://exemplo.com/backdrop.jpg",
    "plot": "Sinopse da série...",
    "cast": "Ator 1, Atriz 2",
    "director": "Diretor",
    "genre": "Drama",
    "releaseDate": "2020-01-01",
    "rating": "9.0",
    "category_id": "3"
  }
]
```

#### 4. Informações Detalhadas de Série

**Endpoint:** `GET /player_api.php?username={user}&password={pass}&action=get_series_info&series_id={id}`

**Resposta:**
```json
{
  "info": {
    "name": "Série Example",
    "cover": "http://exemplo.com/backdrop.jpg",
    "plot": "Sinopse completa...",
    "rating": "9.0",
    "year": "2020"
  },
  "seasons": [
    {
      "season_number": 1,
      "name": "Temporada 1",
      "episodes": [
        {
          "id": "22222",
          "title": "Episódio 1",
          "container_extension": "mp4",
          "info": {
            "plot": "Sinopse do episódio...",
            "rating": "8.8",
            "duration": "3600"
          }
        }
      ]
    }
  ]
}
```

#### 5. Categorias

**Para Canais:** `GET /player_api.php?username={user}&password={pass}&action=get_live_categories`
**Para Filmes:** `GET /player_api.php?username={user}&password={pass}&action=get_vod_categories`
**Para Séries:** `GET /player_api.php?username={user}&password={pass}&action=get_series_categories`

**Resposta padrão:**
```json
[
  {
    "category_id": "1",
    "category_name": "Categoria Example",
    "parent_id": "0"
  }
]
```

### URLs de Stream

#### Canais ao Vivo
```
http://servidor.com:porta/live/{username}/{password}/{stream_id}.ts
```

#### Filmes
```
http://servidor.com:porta/movie/{username}/{password}/{stream_id}.{ext}
```

#### Episódios de Série
```
http://servidor.com:porta/series/{username}/{password}/{episode_id}.{ext}
```

## M3U Playlists

### Formato M3U8

O TarTV suporta o formato M3U8 padrão com extensões:

```m3u
#EXTM3U
#EXTINF:-1 tvg-id="canal1" tvg-name="Canal Example" tvg-logo="http://exemplo.com/logo.png" group-title="Categoria",Canal Example
http://servidor.com/stream/canal1.m3u8
#EXTINF:-1 tvg-id="canal2" tvg-name="Outro Canal" tvg-logo="http://exemplo.com/logo2.png" group-title="Outra Categoria",Outro Canal
http://servidor.com/stream/canal2.m3u8
```

### Atributos Suportados

| Atributo | Descrição | Obrigatório |
|----------|-----------|-------------|
| `tvg-id` | ID único do canal para EPG | Não |
| `tvg-name` | Nome técnico do canal | Não |
| `tvg-logo` | URL do logo/ícone | Não |
| `group-title` | Categoria/grupo do canal | Não |

### Processamento M3U

O `M3UParserService` processa playlists M3U com as seguintes funcionalidades:

1. **Validação de formato**
   - Verifica header `#EXTM3U`
   - Valida sintaxe dos entries

2. **Extração de metadados**
   - Parse de atributos EXTINF
   - Extração de nome do canal
   - Categorização automática

3. **Conversão para modelos**
   - Cria objetos `Channel` padronizados
   - Aplica valores padrão quando necessário

## Implementação nos Services

### AuthService

**Métodos de autenticação:**

```dart
// Xtream Codes
Future<bool> loginXtream(String server, String username, String password)

// M3U URL
Future<bool> loginM3UUrl(String url)

// M3U Arquivo
Future<bool> loginM3UFile(String filePath)
```

### ContentService

**Inicialização baseada no método de auth:**

```dart
switch (authMethod) {
  case AuthMethod.xtream:
    contentService.initializeXtream(serverUrl, username, password);
    break;
  case AuthMethod.m3uUrl:
  case AuthMethod.m3uFile:
    contentService.initializeM3U();
    break;
}
```

### XtreamService

**Métodos principais:**

```dart
Future<List<Channel>> getLiveStreams({String? categoryId})
Future<List<Movie>> getVodStreams({String? categoryId})
Future<List<Series>> getSeries({String? categoryId})
Future<Series?> getSeriesInfo(String seriesId)
```

### M3UParserService

**Processamento de playlists:**

```dart
static List<Channel> parseM3UContent(String content)
static Map<String, String> _parseExtInf(String extinf)
static bool isValidM3U(String content)
```

## Tratamento de Erros

### Códigos de Status HTTP

| Código | Significado | Ação |
|--------|-------------|------|
| 200 | Sucesso | Processar resposta |
| 401 | Não autorizado | Reautenticar |
| 403 | Proibido | Verificar credenciais |
| 404 | Não encontrado | Servidor inválido |
| 500 | Erro interno | Tentar novamente |

### Erros Específicos do Xtream

```json
{
  "user_info": {
    "auth": 0,
    "status": "Expired"
  }
}
```

**Tratamentos implementados:**
- ✅ Conta expirada
- ✅ Credenciais inválidas  
- ✅ Limite de conexões
- ✅ Servidor indisponível

### Erros M3U

- ✅ Arquivo não encontrado
- ✅ Formato M3U inválido
- ✅ URLs de stream inacessíveis
- ✅ Encoding de caracteres

## Rate Limiting

### Xtream Codes
- Máximo 10 requisições por segundo
- Timeout padrão: 30 segundos
- Retry automático: 3 tentativas

### M3U Processing
- Parse assíncrono para arquivos grandes
- Processamento em chunks para performance
- Validação progressiva

## Caching Strategy

### Xtream Data
```dart
// Cache por 1 hora
final cacheKey = 'xtream_channels_${categoryId ?? 'all'}';
await prefs.setString(cacheKey, json.encode(channels));
```

### M3U Data  
```dart
// Cache persistente até mudança de arquivo
await prefs.setString('m3u_content', content);
await prefs.setString('m3u_channels', json.encode(channels));
```

## Monitoramento e Debug

### Logs Implementados

```dart
debugPrint('🔗 Xtream API Request: $endpoint');
debugPrint('📡 Response Status: ${response.statusCode}');
debugPrint('📊 Channels loaded: ${channels.length}');
debugPrint('⚠️ Erro na requisição: $error');
```

### Métricas Coletadas

- ✅ Tempo de resposta da API
- ✅ Taxa de erro por endpoint
- ✅ Tamanho do cache
- ✅ Performance do parser M3U

## Extensibilidade

### Novos Providers

Para adicionar novos tipos de fonte IPTV:

1. Criar novo service (`NewProviderService`)
2. Implementar interface padrão
3. Adicionar ao `ContentService`
4. Configurar autenticação no `AuthService`

### Exemplo de Implementação

```dart
abstract class IPTVProvider {
  Future<List<Channel>> getChannels();
  Future<List<Movie>> getMovies();
  Future<List<Series>> getSeries();
}

class NewProviderService implements IPTVProvider {
  // Implementação específica
}
```

Esta arquitetura de API garante:
- 🔄 **Compatibilidade**: Suporte aos padrões da indústria
- 🚀 **Performance**: Cache e otimizações
- 🛡️ **Robustez**: Tratamento completo de erros
- 📈 **Escalabilidade**: Fácil adição de novos providers
