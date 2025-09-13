@echo off
echo ========================================
echo   Configuracao Android TV - Sem Admin
echo ========================================

REM 1. Para processos Java
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul

REM 2. Cria diretorio .gradle se nao existir
if not exist "%USERPROFILE%\.gradle" mkdir "%USERPROFILE%\.gradle"

REM 3. Configuracoes de memoria no gradle.properties do usuario
echo [INFO] Configurando memoria do Gradle (usuario)...
echo org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError > "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.daemon=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.parallel=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.caching=true >> "%USERPROFILE%\.gradle\gradle.properties"

REM 4. Configuracoes de memoria no projeto
echo [INFO] Configurando memoria no projeto...
echo org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m > "android\gradle.properties"
echo org.gradle.daemon=true >> "android\gradle.properties"
echo org.gradle.parallel=true >> "android\gradle.properties"

REM 5. Limpa builds antigos
echo [INFO] Limpando builds antigos...
if exist "build" rmdir /s /q "build"
if exist "android\build" rmdir /s /q "android\build"
if exist "android\app\build" rmdir /s /q "android\app\build"

REM 6. Limpa cache do Flutter
echo [INFO] Limpando cache do Flutter...
flutter clean

REM 7. Verifica configuracao do Flutter
echo [INFO] Verificando configuracao do Flutter...
flutter doctor

echo ========================================
echo Configuracao concluida!
echo ========================================
echo Agora tente:
echo 1. Abrir o Android Studio
echo 2. Abrir o AVD Manager
echo 3. Iniciar o Android TV (1080p)
echo.
pause
