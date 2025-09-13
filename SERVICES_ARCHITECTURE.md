# TarTV - Services & Architecture Documentation

## 🏗️ **Provider Architecture Overview**

### **Main.dart Provider Setup**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => ThemeService()),
    ChangeNotifierProvider(create: (_) => ContentService()),
    ChangeNotifierProvider(create: (_) => DownloadService()),
    ChangeNotifierProvider(create: (_) => LayoutService()..init()),
    ChangeNotifierProvider(create: (_) => PlayerSettingsService()),
    ChangeNotifierProvider(create: (_) => FavoritesService()..init()),
  ],
  child: Consumer<ThemeService>(...)
)
```

---

## 📋 **Service Documentation**

### 🔐 **AuthService**
**Purpose**: Handle user authentication and server connection
**Key Methods**:
- `login(server, username, password)` - Xtream/M3U login
- `logout()` - Clear credentials and redirect to login
- `isLoggedIn()` - Check authentication status
- `getCurrentUser()` - Get current user info

**State Variables**:
- `isAuthenticated: bool`
- `serverInfo: Map<String, dynamic>`
- `userInfo: Map<String, dynamic>`

**Usage**:
```dart
final authService = Provider.of<AuthService>(context, listen: false);
await authService.login(server, username, password);
```

---

### 🎨 **ThemeService**
**Purpose**: Manage app theme and colors
**Key Properties**:
- `primaryColor: Color(0xFF2B5CB0)` - TarSystem blue
- `isDarkMode: bool` - Theme mode toggle
- `customTheme: ThemeData` - Complete theme configuration

**Key Methods**:
- `toggleTheme()` - Switch between dark/light
- `updatePrimaryColor(Color color)` - Change app color
- `getThemeData()` - Get current theme

**Usage**:
```dart
final themeService = Provider.of<ThemeService>(context);
return MaterialApp(theme: themeService.getThemeData());
```

---

### 📺 **ContentService**
**Purpose**: Fetch and manage IPTV content (channels, movies, series)
**Key Methods**:
- `loadChannels()` - Fetch live TV channels
- `loadMovies()` - Fetch movie library
- `loadSeries()` - Fetch series library
- `searchContent(query)` - Search across all content
- `getStreamUrl(id, type)` - Get direct stream URL

**State Variables**:
- `channels: List<Channel>`
- `movies: List<Movie>`
- `series: List<Series>`
- `isLoading: bool`

**Usage**:
```dart
final contentService = Provider.of<ContentService>(context);
await contentService.loadChannels();
```

---

### ⭐ **FavoritesService**
**Purpose**: Manage user favorites across content types
**Key Methods**:
- `init()` - Initialize favorites from storage
- `addToFavorites(item, type)` - Add content to favorites
- `removeFromFavorites(itemId)` - Remove from favorites
- `isFavorite(itemId)` - Check if item is favorited
- `getFavoritesByType(type)` - Get favorites filtered by type

**State Variables**:
- `favorites: List<FavoriteItem>`
- `favoriteChannels: List<Channel>`
- `favoriteMovies: List<Movie>`
- `favoriteSeries: List<Series>`

**Usage**:
```dart
final favoritesService = Provider.of<FavoritesService>(context, listen: false);
await favoritesService.addToFavorites(movie, 'movie');
```

---

### 📥 **DownloadService**
**Purpose**: Handle content downloads and offline storage
**Key Methods**:
- `downloadMovie(movie, quality)` - Download movie file
- `downloadEpisode(series, episode)` - Download series episode
- `pauseDownload(downloadId)` - Pause active download
- `resumeDownload(downloadId)` - Resume paused download
- `cancelDownload(downloadId)` - Cancel download
- `getDownloads()` - Get all downloads list

**State Variables**:
- `downloads: List<DownloadItem>`
- `activeDownloads: Map<String, DownloadProgress>`
- `downloadPath: String`

**Usage**:
```dart
final downloadService = Provider.of<DownloadService>(context, listen: false);
await downloadService.downloadMovie(movie, 'HD');
```

---

### 🎮 **PlayerSettingsService**
**Purpose**: Manage video player preferences and settings
**Key Methods**:
- `updateAutoplay(bool enabled)` - Toggle autoplay
- `updateWakeLock(bool enabled)` - Keep screen on during playback
- `updateQuality(String quality)` - Set preferred quality
- `updateBufferSize(int seconds)` - Set buffer duration
- `getPlayerSettings()` - Get current settings

**State Variables**:
- `autoplay: bool`
- `wakeLock: bool`
- `preferredQuality: String`
- `bufferDuration: int`
- `showSubtitles: bool`

**Usage**:
```dart
final playerService = Provider.of<PlayerSettingsService>(context);
playerService.updateAutoplay(true);
```

---

### 📱 **LayoutService**
**Purpose**: Manage responsive layout and grid configurations
**Key Methods**:
- `init()` - Initialize layout preferences
- `updateGridColumns(int columns)` - Set grid column count
- `getOptimalColumns(screenWidth)` - Calculate best column count
- `updateCardAspectRatio(double ratio)` - Set card proportions

**State Variables**:
- `gridColumns: int` - Current column count (2-5)
- `cardAspectRatio: double` - Card width/height ratio
- `screenBreakpoints: Map<String, double>`

**Usage**:
```dart
final layoutService = Provider.of<LayoutService>(context);
layoutService.updateGridColumns(3);
```

---

## 🗂️ **Models Documentation**

### 📺 **Channel Model**
```dart
class Channel {
  final String id;
  final String name;
  final String icon;
  final String streamUrl;
  final String category;
  final bool isLive;
  final String epgId;
}
```

### 🎬 **Movie Model**
```dart
class Movie {
  final String id;
  final String title;
  final String poster;
  final String backdrop;
  final String description;
  final String year;
  final String genre;
  final String rating;
  final String duration;
  final String streamUrl;
  final List<String> availableQualities;
}
```

### 📺 **Series Model**
```dart
class Series {
  final String id;
  final String title;
  final String poster;
  final String backdrop;
  final String description;
  final String year;
  final String genre;
  final String rating;
  final List<Season> seasons;
}

class Season {
  final String id;
  final int seasonNumber;
  final List<Episode> episodes;
}

class Episode {
  final String id;
  final String title;
  final String description;
  final int episodeNumber;
  final String streamUrl;
  final String thumbnail;
}
```

---

## 🔄 **Service Interactions**

### **Content Loading Flow**:
1. **AuthService** validates credentials
2. **ContentService** fetches content from server
3. **FavoritesService** marks favorited items
4. **LayoutService** determines display format
5. **UI renders** content grid

### **Playback Flow**:
1. User selects content
2. **ContentService** provides stream URL
3. **PlayerSettingsService** applies user preferences
4. **VideoPlayerScreen** starts playback
5. **DownloadService** tracks viewing (if needed)

### **Search Flow**:
1. User types in search field
2. **ContentService** filters loaded content
3. **FavoritesService** maintains favorite status
4. **UI updates** with filtered results

---

## 📊 **State Management Patterns**

### **Provider Pattern Usage**:
```dart
// Listen to changes
Consumer<ContentService>(
  builder: (context, contentService, child) {
    return contentService.isLoading 
      ? CircularProgressIndicator()
      : ContentGrid(items: contentService.movies);
  },
)

// Access without listening
final authService = Provider.of<AuthService>(context, listen: false);
authService.logout();

// Selector for specific properties
Selector<FavoritesService, List<Movie>>(
  selector: (context, service) => service.favoriteMovies,
  builder: (context, favoriteMovies, child) {
    return MovieGrid(movies: favoriteMovies);
  },
)
```

### **Service Communication**:
- Services communicate via Provider.of<Service>(context, listen: false)
- Use notifyListeners() to update UI
- Avoid circular dependencies between services
- Initialize dependent services in correct order

---

## 🛡️ **Error Handling**

### **Network Errors**:
- Timeout handling in ContentService
- Retry mechanisms for failed requests
- Offline mode detection
- User-friendly error messages

### **Authentication Errors**:
- Invalid credentials handling
- Session expiration detection
- Automatic re-authentication
- Secure credential storage

### **Playback Errors**:
- Stream unavailable handling
- Format compatibility checks
- Alternative quality fallback
- Network buffering management

---

*Last updated: 01/09/2025*
*For technical reference and new AI assistants*
