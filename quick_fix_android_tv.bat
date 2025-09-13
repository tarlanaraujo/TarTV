@echo off
echo ========================================
echo   Solução Rápida - Android TV Emulator
echo ========================================

REM 1. Define variáveis do Android SDK
set "ANDROID_SDK_ROOT=C:\Users\Windows Lite BR\AppData\Local\Android\sdk"
set "ANDROID_HOME=%ANDROID_SDK_ROOT%"

REM 2. Para processos conflitantes
echo [INFO] Limpando processos...
taskkill /f /im "emulator.exe" 2>nul
taskkill /f /im "qemu-system-x86_64.exe" 2>nul

REM 3. Adiciona ferramentas ao PATH
set "PATH=%ANDROID_SDK_ROOT%\emulator;%ANDROID_SDK_ROOT%\platform-tools;%PATH%"

REM 4. Lista AVDs existentes
echo [INFO] AVDs existentes:
cd /d "%USERPROFILE%\.android\avd"
dir /b *.avd 2>nul

REM 5. Verifica se existe algum AVD de TV
echo.
echo [INFO] Procurando AVDs de TV...
if exist "*tv*.avd" (
    echo Encontrado AVD de TV existente
    for /d %%i in (*tv*.avd) do (
        set TVD_NAME=%%~ni
        goto :start_emulator
    )
)

if exist "*Television*.avd" (
    echo Encontrado AVD Television existente
    for /d %%i in (*Television*.avd) do (
        set TVD_NAME=%%~ni
        goto :start_emulator
    )
)

echo [INFO] Nenhum AVD de TV encontrado. Criando um novo...
cd /d C:\FlutterProjects\TarTV

REM 6. Cria AVD básico usando Flutter
echo [INFO] Criando AVD via Flutter...
flutter emulators --create --name AndroidTV_Simple

if %errorlevel% == 0 (
    set TVD_NAME=AndroidTV_Simple
    goto :start_emulator
)

echo [ERROR] Falha ao criar AVD via Flutter
echo [INFO] Tentando criar manualmente...

REM 7. Tenta criar AVD diretamente
echo no | "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" create avd -n AndroidTV_Manual -k "system-images;android-34;google_apis;x86_64" -d "tv_1080p" 2>nul

if %errorlevel% == 0 (
    set TVD_NAME=AndroidTV_Manual
    goto :start_emulator
)

echo [ERROR] Não foi possível criar AVD automaticamente
echo [SOLUÇÃO] Execute o Android Studio e crie um AVD de TV manualmente:
echo 1. Abra Android Studio
echo 2. Vá em Tools > AVD Manager
echo 3. Clique em "Create Virtual Device"
echo 4. Escolha categoria "TV"
echo 5. Selecione um dispositivo (ex: Television 1080p)
echo 6. Escolha uma system image (API 30 ou superior)
echo 7. Nomeie como "AndroidTV_Manual"
echo 8. Execute este script novamente
pause
exit /b 1

:start_emulator
echo.
echo [INFO] Iniciando emulador: %TVD_NAME%
echo [INFO] Aguarde alguns minutos para o emulador carregar...

REM 8. Inicia o emulador com configurações otimizadas
"%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd %TVD_NAME% -no-snapshot-save -no-snapshot-load -gpu auto -memory 2048

if %errorlevel% neq 0 (
    echo [ERROR] Falha com configurações padrão. Tentando modo compatibilidade...
    "%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd %TVD_NAME% -no-snapshot-save -no-snapshot-load -gpu swiftshader_indirect -memory 1024
)

echo.
echo [INFO] Script finalizado
pause
