@echo off
echo ===========================================
echo    TarTV - Build Rapida para Testes
echo ===========================================

REM Aumentar memoria do Gradle para builds mais rapidas
set GRADLE_OPTS=-Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

echo Fazendo build debug rapida...
flutter build apk --debug --split-per-abi

echo.
echo ===========================================
echo Build concluida!
echo APK localizada em: build\app\outputs\flutter-apk\
echo ========================
===================
echo.
dir build\app\outputs\flutter-apk\*.apk

pause
