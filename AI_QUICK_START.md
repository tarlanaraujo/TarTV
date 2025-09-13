# TarTV - Quick Start Guide for AI Assistants

## 🚀 **CRITICAL INFO - READ FIRST**

**Status**: ✅ APP 100% FUNCTIONAL - DO NOT BREAK EXISTING CODE!

**Last successful build**: 23.3MB APK (01/09/2025)
**User feedback**: "ficou show demais" (working perfectly)

---

## 🎯 **What's WORKING (DON'T TOUCH):**

### ✅ **Core Features**:
- 5-tab navigation (Live TV, Movies, Series, Favorites, Settings)
- Real-time search on all content types
- Favorites system fully functional
- Login/logout system working
- Downloads system operational
- Complete settings screen
- Video player with native Android support

### ✅ **UI/UX**:
- Blue theme (Color(0xFF2B5CB0)) restored
- Responsive grid (2-5 columns user configurable)
- Clean search interface with clear buttons
- Developer info: "Tarlan Araújo / Contact: 88981222492"

---

## 🚨 **NEVER MODIFY THESE FILES:**
- `lib/main.dart` - All providers correctly registered
- `lib/screens/home_screen.dart` - **COMPLETELY REWRITTEN** - WORKING PERFECTLY
- `android/app/build.gradle` - SDK 35 configured correctly
- `lib/services/theme_service.dart` - Blue color restored

---

## 📱 **Project Context:**
- **Platform**: Android IPTV app (NOT TV - regular mobile)
- **Architecture**: Flutter + Provider pattern
- **Connection**: Xtream Codes + M3U support
- **Focus**: Resolve CORS issues with native player

---

## 🔧 **Build Commands:**
```bash
# Release (production)
flutter build apk --release

# Debug (development)  
flutter build apk --debug

# If issues
flutter clean && flutter pub get
```

---

## 🎯 **Next Priority Tasks:**
1. **EPG** (TV guide/programming)
2. **Categories** (better content organization)
3. **Player improvements** (subtitles, quality selection)
4. **Premium features** (payment integration with "Asaas banco")

---

## ⚠️ **IMPORTANT NOTES:**
- Test on ANDROID device (web has CORS issues)
- User is satisfied with current state
- Any new features should be ADDITIONS, not modifications
- VideoPlayerScreen expects `videoUrl` parameter (not `url`)
- FavoritesService uses `init()` method (not `loadFavorites()`)

---

## 👤 **User Profile:**
- **Developer**: Tarlan Araújo (88981222492)
- **Experience**: Positive, app working perfectly on his device
- **Preference**: Keep current UI, add new features incrementally

**REMEMBER**: This is a successful, working app. Build upon it, don't break it!
