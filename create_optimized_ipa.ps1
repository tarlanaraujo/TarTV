# Script PowerShell para criar IPA otimizado para iOS 18.6.2
Write-Host "Criando IPA otimizado para iOS 18.6.2..." -ForegroundColor Green

# Verificar se o arquivo Runner.app existe
if (Test-Path "Runner.app") {
    # Criar diretório temporário
    New-Item -ItemType Directory -Path "temp_ipa\Payload" -Force | Out-Null
    
    # Copiar app
    Copy-Item -Path "Runner.app" -Destination "temp_ipa\Payload\" -Recurse -Force
    
    # Criar arquivo IPA (usando PowerShell)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $source = Join-Path $PWD "temp_ipa"
    $destination = Join-Path $PWD "TarTV-iOS18-OPTIMIZED.ipa"
    
    if (Test-Path $destination) {
        Remove-Item $destination -Force
    }
    
    [System.IO.Compression.ZipFile]::CreateFromDirectory($source, $destination)
    
    # Limpar diretório temporário
    Remove-Item "temp_ipa" -Recurse -Force
    
    Write-Host "✅ IPA criado com sucesso: TarTV-iOS18-OPTIMIZED.ipa" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo Runner.app não encontrado!" -ForegroundColor Red
}