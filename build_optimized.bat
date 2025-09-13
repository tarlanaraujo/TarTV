@echo off
echo Otimizando build do TarTV...

REM Limpar cache do Gradle
echo Limpando cache do Gradle...
cd android
call gradlew clean
cd ..

REM Migrar para AndroidX (recomendado)
echo Migrando para AndroidX...
flutter pub get
dart pub global activate flutter_migrate_to_android_x
dart pub global run flutter_migrate_to_android_x

REM Build debug rapida para testar
echo Fazendo build debug...
flutter build apk --debug

echo Build concluida! APK em: build\app\outputs\flutter-apk\app-debug.apk
pause
