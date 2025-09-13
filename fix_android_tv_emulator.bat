@echo off
echo ========================================
echo   Correção do Android TV Emulator
echo ========================================

REM 1. Para processos conflitantes primeiro
call "%~dp0fix_emulator_conflicts.bat"

REM 2. Configura variáveis do Android SDK usando flutter config
echo [INFO] Configurando Android SDK...
set ANDROID_SDK_ROOT=C:\Users\Windows Lite BR\AppData\Local\Android\sdk
set ANDROID_HOME=%ANDROID_SDK_ROOT%

echo [INFO] Android SDK: %ANDROID_SDK_ROOT%

REM 3. Adiciona tools ao PATH
set "PATH=%ANDROID_SDK_ROOT%\tools;%ANDROID_SDK_ROOT%\tools\bin;%ANDROID_SDK_ROOT%\platform-tools;%ANDROID_SDK_ROOT%\emulator;%PATH%"

REM 4. Testa se o sdkmanager funciona
echo [INFO] Testando sdkmanager...
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Usando sdkmanager alternativo...
    set "PATH=%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin;%PATH%"
)

REM 5. Lista system images disponíveis
echo [INFO] Verificando system images instaladas...
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager" --list | findstr "system-images.*tv" 2>nul

REM 6. Remove AVDs existentes problemáticos
echo [INFO] Limpando AVDs problemáticos...
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" delete avd -n Television_720p 2>nul
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" delete avd -n tv_api30 2>nul

REM 7. Lista AVDs para ver o que temos
echo [INFO] AVDs disponíveis:
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" list avd

REM 8. Cria novo Android TV AVD se system image estiver disponível
echo [INFO] Criando novo Android TV AVD...
"%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" list target | findstr "android-30" >nul
if %errorlevel% == 0 (
    echo no | "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" create avd -n AndroidTV_Fixed -k "system-images;android-30;google_apis;x86_64" -d "tv_1080p"
) else (
    echo [INFO] Usando API mais recente disponível...
    echo no | "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\avdmanager" create avd -n AndroidTV_Fixed -k "system-images;android-34;google_apis;x86_64" -d "tv_1080p"
)

REM 9. Configura o AVD para melhor compatibilidade
echo [INFO] Configurando AVD...
set "AVD_PATH=%USERPROFILE%\.android\avd\AndroidTV_Fixed.avd"

if exist "%AVD_PATH%" (
    (
    echo hw.ramSize=2048
    echo hw.heap=256
    echo vm.heapSize=128
    echo hw.accelerometer=no
    echo hw.gps=no
    echo hw.battery=no
    echo hw.camera.back=none
    echo hw.camera.front=none
    echo hw.audioInput=no
    echo hw.audioOutput=yes
    echo disk.dataPartition.size=6144M
    echo hw.gpu.enabled=yes
    echo hw.gpu.mode=auto
    echo runtime.network.latency=none
    echo runtime.network.speed=full
    echo hw.keyboard=yes
    echo hw.dPad=yes
    echo hw.mainKeys=yes
    echo hw.trackBall=no
    echo avd.ini.displayname=Android TV Fixed
    ) > "%AVD_PATH%\config.ini"

    echo [SUCCESS] Android TV AVD configurado com sucesso!
) else (
    echo [ERROR] Falha ao criar AVD. Verifique se as system images estão instaladas.
)

echo [INFO] Nome do AVD: AndroidTV_Fixed
echo.
