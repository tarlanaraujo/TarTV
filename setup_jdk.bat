@echo off
echo ========================================
echo    Configurando JDK 24 para Flutter
echo ========================================

REM 1. Verifica se o JDK existe
if not exist "C:\jdk-24.0.1\bin\java.exe" (
    echo [ERRO] JDK nao encontrado em C:\jdk-24.0.1
    pause
    exit /b 1
)
echo [OK] JDK encontrado em C:\jdk-24.0.1

REM 2. Configura JAVA_HOME
setx JAVA_HOME "C:\jdk-24.0.1" /M

REM 3. Adiciona JDK ao PATH
setx PATH "%PATH%;C:\jdk-24.0.1\bin" /M

REM 4. Configura Flutter para usar o JDK
flutter config --jdk-dir="C:\jdk-24.0.1"

REM 5. Mostra versoes
echo.
echo --- Versao do Java ---
"C:\jdk-24.0.1\bin\java.exe" -version
echo --- Versao do Javac ---
"C:\jdk-24.0.1\bin\javac.exe" -version
echo --- Status do Flutter ---
flutter doctor

echo ========================================
echo Configuracao concluida!
echo ========================================
echo Feche e reabra o VS Code antes de continuar.
pause