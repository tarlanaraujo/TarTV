@echo off
echo ======================================
echo TarTV - Build Release Script
echo ======================================

echo Limpando projeto...
flutter clean

echo Baixando dependencias...
flutter pub get

echo Verificando dependencias...
flutter pub outdated

echo Iniciando build release...
flutter build apk --release --verbose

echo ======================================
echo Build concluido!
echo Verificando arquivo gerado...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo APK gerado com sucesso!
    echo Localizacao: build\app\outputs\flutter-apk\app-release.apk
    dir "build\app\outputs\flutter-apk\app-release.apk"
) else (
    echo ERRO: APK nao foi gerado!
)

pause
