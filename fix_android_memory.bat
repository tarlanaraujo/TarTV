@echo off
echo ========================================
echo   Corrigindo problema de memoria Android
echo ========================================

REM 1. Para processos Java que podem estar rodando
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul

REM 2. Limpa cache do Gradle
echo [INFO] Limpando cache do Gradle...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
)

REM 3. Configura variaveis de memoria para o Gradle
echo [INFO] Configurando memoria do Gradle...
setx GRADLE_OPTS "-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError" /M

REM 4. Cria arquivo gradle.properties com configuracoes de memoria
echo [INFO] Criando configuracoes de memoria...
echo org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError > "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.daemon=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.parallel=true >> "%USERPROFILE%\.gradle\gradle.properties"
echo org.gradle.caching=true >> "%USERPROFILE%\.gradle\gradle.properties"

REM 5. Configura o JDK 17 (ajusta o caminho se necessario)
echo [INFO] Procurando JDK 17...
if exist "C:\Program Files\Java\jdk-17" (
    setx JAVA_HOME "C:\Program Files\Java\jdk-17" /M
    echo [OK] JDK 17 encontrado e configurado
) else if exist "C:\Program Files\Eclipse Adoptium\jdk-17" (
    setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17" /M
    echo [OK] JDK 17 Adoptium encontrado e configurado
) else (
    echo [AVISO] JDK 17 nao encontrado no local padrao
    echo Por favor, verifique onde o JDK 17 foi instalado
)

REM 6. Limpa build do projeto
echo [INFO] Limpando build do projeto...
cd /d "C:\FlutterProjects\TarTV"
flutter clean
cd android
call gradlew clean

echo ========================================
echo Correcao concluida!
echo ========================================
echo Agora tente abrir o Android TV Manager novamente.
echo Se ainda der erro, reinicie o computador.
pause
