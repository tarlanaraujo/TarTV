@echo off
echo ========================================
echo   Teste Android TV + Flutter
echo ========================================

REM 1. Verifica se o emulador está rodando
echo [INFO] Verificando status do emulador...
adb devices
echo.

adb devices | find "emulator" | find "device" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Nenhum emulador detectado!
    echo Execute primeiro: start_android_tv.bat
    pause
    exit /b 1
)

REM 2. Limpa e prepara o projeto Flutter
echo [INFO] Preparando projeto Flutter...
flutter clean
flutter pub get

REM 3. Verifica dependências do Flutter
echo [INFO] Verificando Flutter doctor...
flutter doctor

REM 4. Lista devices disponíveis
echo [INFO] Devices disponíveis:
flutter devices

REM 5. Testa a instalação no Android TV
echo [INFO] Instalando app no Android TV...
flutter run --device-id emulator-5554 --release

echo ========================================
echo Teste concluído!
echo ========================================
pause
