@echo off
echo ========================================
echo REINSTALAÇÃO COMPLETA DO AMBIENTE
echo ========================================

echo.
echo PASSO 1: Download e instalação do JDK 17
echo ========================================
echo Baixando JDK 17...

:: Criar pasta temporária
mkdir C:\temp_downloads 2>nul

:: Download JDK 17 (OpenJDK)
powershell -Command "& {Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe' -OutFile 'C:\temp_downloads\jdk-17_windows-x64_bin.exe'}"

echo.
echo Executando instalador do JDK...
start /wait C:\temp_downloads\jdk-17_windows-x64_bin.exe

echo.
echo PASSO 2: Download do Android Studio
echo ========================================
echo Baixando Android Studio...

powershell -Command "& {Invoke-WebRequest -Uri 'https://redirector.gvt1.com/edgedl/android/studio/install/2023.3.1.18/android-studio-2023.3.1.18-windows.exe' -OutFile 'C:\temp_downloads\android-studio-windows.exe'}"

echo.
echo Executando instalador do Android Studio...
start /wait C:\temp_downloads\android-studio-windows.exe

echo.
echo PASSO 3: Configuração das variáveis de ambiente
echo ========================================

:: Detectar instalação do JDK
for /d %%i in ("C:\Program Files\Java\jdk-17*") do set JAVA_HOME=%%i
for /d %%i in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do set JAVA_HOME=%%i

if defined JAVA_HOME (
    echo JDK encontrado em: %JAVA_HOME%
    setx JAVA_HOME "%JAVA_HOME%"
) else (
    echo AVISO: JDK não encontrado automaticamente
    echo Você precisará configurar JAVA_HOME manualmente
)

:: Configurar Android SDK
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
setx ANDROID_HOME "%ANDROID_HOME%"
setx ANDROID_SDK_ROOT "%ANDROID_HOME%"

echo.
echo PASSO 4: Verificação da instalação
echo ========================================
echo Verificando Java...
java -version

echo.
echo Verificando Flutter...
flutter doctor

echo.
echo ========================================
echo INSTALAÇÃO CONCLUÍDA!
echo ========================================
echo.
echo PRÓXIMOS PASSOS MANUAIS:
echo 1. Abrir Android Studio
echo 2. Ir em Tools > SDK Manager
echo 3. Instalar Android SDK Platform-Tools
echo 4. Instalar Android SDK Build-Tools (versão mais recente)
echo 5. Instalar Android API 34 (ou mais recente)
echo 6. Ir em Tools > AVD Manager
echo 7. Criar um novo AVD (recomendado: Pixel 7 com API 34)
echo.
echo Após isso, execute: flutter doctor --android-licenses
echo.
pause
