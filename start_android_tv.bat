@echo off
echo ========================================
echo   Android TV Emulator Startup
echo ========================================

REM 1. Verifica se o ambiente está limpo
echo [INFO] Verificando ambiente...
tasklist | find "ldplayer" >nul
if %errorlevel% == 0 (
    echo [ERROR] LDPlayer ainda está executando!
    echo Por favor, feche completamente o LDPlayer e execute novamente.
    pause
    exit /b 1
)

REM 2. Configura variáveis do Android SDK com caminho correto
echo [INFO] Configurando Android SDK...
set "ANDROID_SDK_ROOT=C:\Users\Windows Lite BR\AppData\Local\Android\sdk"
set "ANDROID_HOME=%ANDROID_SDK_ROOT%"

echo [INFO] Android SDK: %ANDROID_SDK_ROOT%

REM 3. Adiciona tools ao PATH temporariamente
set "PATH=%ANDROID_SDK_ROOT%\tools;%ANDROID_SDK_ROOT%\tools\bin;%ANDROID_SDK_ROOT%\platform-tools;%ANDROID_SDK_ROOT%\emulator;%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin;%PATH%"

REM 4. Lista AVDs disponíveis
echo [INFO] AVDs disponíveis:
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" list avd

REM 5. Verifica se o AVD corrigido existe
echo.
echo [INFO] Verificando Android TV AVD...
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" list avd | find "AndroidTV_Fixed" >nul
if %errorlevel% neq 0 (
    echo [INFO] AVD não encontrado. Executando correção...
    call "%~dp0fix_android_tv_emulator.bat"
    if %errorlevel% neq 0 (
        echo [ERROR] Falha na correção do AVD!
        pause
        exit /b 1
    )
)

REM 6. Para processos conflitantes antes de iniciar
echo [INFO] Limpando processos conflitantes...
call "%~dp0fix_emulator_conflicts.bat"

REM 7. Inicia o Android TV Emulator
echo [INFO] Iniciando Android TV Emulator...
echo [INFO] Aguarde... O emulador pode demorar alguns minutos para carregar completamente.
echo.

REM Verifica se o emulador existe primeiro
if not exist "%ANDROID_SDK_ROOT%\emulator\emulator.exe" (
    echo [ERROR] Emulador não encontrado!
    echo [INFO] Verificando instalação do Android SDK...
    pause
    exit /b 1
)

REM Parâmetros otimizados para evitar conflitos
"%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd AndroidTV_Fixed -no-snapshot-save -no-snapshot-load -gpu auto -memory 2048 -cores 2 -netdelay none -netspeed full

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Falha ao iniciar o emulador!
    echo [INFO] Tentando com configurações de fallback...

    REM Tentativa com configurações mais básicas
    "%ANDROID_SDK_ROOT%\emulator\emulator.exe" -avd AndroidTV_Fixed -no-snapshot-save -no-snapshot-load -gpu swiftshader_indirect -memory 1024

    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Emulador falhou mesmo com configurações básicas!
        echo [HELP] Possíveis soluções:
        echo 1. Execute fix_android_tv_emulator.bat como administrador
        echo 2. Verifique se a virtualização está habilitada no BIOS
        echo 3. Desinstale completamente outros emuladores Android
        echo 4. Reinicie o computador e tente novamente
        echo 5. Verifique se há atualizações do Android SDK
        pause
        exit /b 1
    )
)

echo.
echo [SUCCESS] Android TV Emulator iniciado com sucesso!
pause
