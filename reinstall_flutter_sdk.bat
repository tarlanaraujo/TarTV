@echo off
echo ============================================
echo Reinstalando Flutter SDK
echo ============================================

echo.
echo 1. Verificando versao atual do Flutter...
flutter --version

echo.
echo 2. Limpando cache do Flutter...
flutter clean
flutter pub cache clean

echo.
echo 3. Baixando e reinstalando Flutter SDK...
echo Por favor, siga os passos:
echo - Va para: https://docs.flutter.dev/get-started/install/windows
echo - Baixe o ZIP mais recente do Flutter
echo - Extraia para C:\flutter (ou sua pasta preferida)
echo - Atualize o PATH se necessario

echo.
echo 4. Apos reinstalar o SDK, execute:
echo flutter doctor
echo flutter pub get

echo.
echo Pressione qualquer tecla para continuar...
pause
