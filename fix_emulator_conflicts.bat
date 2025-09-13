@echo off
echo ========================================
echo   Corrigindo Conflitos de Emulador
echo ========================================

REM 1. Para todos os processos relacionados a emuladores
echo [INFO] Parando processos conflitantes...
taskkill /f /im "qemu-system-x86_64.exe" 2>nul
taskkill /f /im "emulator.exe" 2>nul
taskkill /f /im "adb.exe" 2>nul
taskkill /f /im "ldplayer.exe" 2>nul
taskkill /f /im "dnplayer.exe" 2>nul

REM 2. Limpa portas ocupadas
echo [INFO] Liberando portas...
netstat -ano | findstr :5554 >nul
if %errorlevel% == 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5554') do taskkill /f /pid %%a
)

netstat -ano | findstr :5555 >nul
if %errorlevel% == 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5555') do taskkill /f /pid %%a
)

REM 3. Reinicia ADB
echo [INFO] Reiniciando ADB...
adb kill-server
timeout /t 2 /nobreak >nul
adb start-server

REM 4. Remove lock files temporários
echo [INFO] Removendo arquivos de lock...
del "%TEMP%\AndroidEmulator\*" /f /q 2>nul
del "%USERPROFILE%\.android\avd\*.lock" /f /q 2>nul

echo [SUCCESS] Conflitos resolvidos!
echo.
