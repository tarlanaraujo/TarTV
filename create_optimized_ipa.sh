#!/bin/bash
# Script para criar IPA otimizado para iOS 18.6.2

echo "Criando IPA otimizado para iOS 18.6.2..."

# Criar diretório temporário
mkdir -p temp_ipa/Payload

# Copiar app
cp -R Runner.app temp_ipa/Payload/

# Criar arquivo IPA
cd temp_ipa
zip -r ../TarTV-iOS18-OPTIMIZED.ipa *
cd ..

# Limpar diretório temporário
rm -rf temp_ipa

echo "IPA criado: TarTV-iOS18-OPTIMIZED.ipa"