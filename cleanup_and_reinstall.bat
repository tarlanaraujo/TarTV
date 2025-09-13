@echo off
echo ========================================
echo LIMPEZA COMPLETA DO AMBIENTE ANDROID
echo ========================================

echo.
echo 1. Parando processos relacionados...
taskkill /f /im "qemu-system-x86_64.exe" 2>nul
taskkill /f /im "emulator.exe" 2>nul
taskkill /f /im "adb.exe" 2>nul
taskkill /f /im "gradle-daemon.exe" 2>nul
taskkill /f /im "java.exe" 2>nul

echo.
echo 2. Limpando cache do Flutter...
flutter clean
flutter pub cache clean

echo.
echo 3. Removendo pastas do Android SDK (se existirem)...
if exist "%LOCALAPPDATA%\Android" (
    echo Removendo %LOCALAPPDATA%\Android...
    rmdir /s /q "%LOCALAPPDATA%\Android" 2>nul
)

if exist "%USERPROFILE%\AppData\Local\Android" (
    echo Removendo %USERPROFILE%\AppData\Local\Android...
    rmdir /s /q "%USERPROFILE%\AppData\Local\Android" 2>nul
)

if exist "C:\Android" (
    echo Removendo C:\Android...
    rmdir /s /q "C:\Android" 2>nul
)

echo.
echo 4. Removendo JDK antigo...
if exist "C:\Program Files\Java" (
    echo Removendo JDKs em C:\Program Files\Java...
    rmdir /s /q "C:\Program Files\Java" 2>nul
)

if exist "C:\Program Files (x86)\Java" (
    echo Removendo JDKs em C:\Program Files (x86)\Java...
    rmdir /s /q "C:\Program Files (x86)\Java" 2>nul
)

echo.
echo 5. Limpando variáveis de ambiente...
setx ANDROID_HOME ""
setx ANDROID_SDK_ROOT ""
setx JAVA_HOME ""

echo.
echo 6. Limpando cache do Gradle...
if exist "%USERPROFILE%\.gradle" (
    rmdir /s /q "%USERPROFILE%\.gradle" 2>nul
)

echo.
echo 7. Limpando AVDs...
if exist "%USERPROFILE%\.android" (
    rmdir /s /q "%USERPROFILE%\.android" 2>nul
)

echo.
echo ========================================
echo LIMPEZA CONCLUÍDA!
echo ========================================
echo.
echo Próximos passos:
echo 1. Instalar JDK 17
echo 2. Instalar Android Studio
echo 3. Configurar SDK e AVD
echo.
pause
