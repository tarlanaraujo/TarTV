@echo off
echo ========================================
echo   Diagnóstico do Android Emulator
echo ========================================

echo [INFO] Verificando configuração do sistema...

REM 1. Verifica virtualização
echo.
echo [CHECK] Virtualização:
systeminfo | findstr /C:"Hyper-V Requirements"

REM 2. Verifica memória disponível
echo.
echo [CHECK] Memória do sistema:
wmic computersystem get TotalPhysicalMemory /format:value

REM 3. Verifica processos conflitantes
echo.
echo [CHECK] Processos de emulador ativos:
tasklist | findstr /I "emulator qemu ldplayer dnplayer bluestacks"

REM 4. Verifica portas em uso
echo.
echo [CHECK] Portas Android em uso:
netstat -an | findstr ":5554\|:5555\|:5037"

REM 5. Verifica configuração do Android SDK
echo.
echo [CHECK] Android SDK:
if defined ANDROID_SDK_ROOT (
    echo ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT%
) else (
    echo ANDROID_SDK_ROOT não definido
)

REM 6. Verifica AVDs existentes
echo.
echo [CHECK] AVDs instalados:
avdmanager list avd 2>nul || echo Erro ao listar AVDs

REM 7. Verifica system images disponíveis
echo.
echo [CHECK] System Images instalados:
avdmanager list target 2>nul || echo Erro ao listar targets

REM 8. Verifica espaço em disco
echo.
echo [CHECK] Espaço em disco (C:):
dir C:\ | findstr "bytes free"

REM 9. Verifica variáveis de ambiente importantes
echo.
echo [CHECK] Variáveis de ambiente:
echo JAVA_HOME=%JAVA_HOME%
echo PATH contém Android SDK:
echo %PATH% | findstr Android >nul && echo SIM || echo NÃO

echo.
echo ========================================
echo   Diagnóstico concluído
echo ========================================
pause
