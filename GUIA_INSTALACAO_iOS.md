# 🔧 Guia Completo de Instalação - TarTV no iOS 18.6.2

## ⚡ QUICK FIX - Problemas Identificados e Soluções

### 🚨 Principais Causas dos Crashes:
1. **Falta de configurações iOS 18+** - ✅ CORRIGIDO
2. **Permissões insuficientes** - ✅ CORRIGIDO  
3. **Configurações de segurança ATS** - ✅ CORRIGIDO
4. **IPA mal empacotado** - ✅ CORRIGIDO

---

## 📱 IPAs Disponíveis (em ordem de recomendação para iOS 18.6.2):

1. **TarTV-iOS18-OPTIMIZED.ipa** ⭐ **RECOMENDADO** - Recém criado com correções
2. **TarTV-iOS18-FIXED.ipa** - Segunda opção
3. **TarTV-SIMPLE.ipa** - Versão mais básica (fallback)

---

## 🛠️ Ferramentas de Sideloading GRATUITAS

### 1. **Sideloadly** (RECOMENDADO) 🥇
- **Download:** https://sideloadly.io
- **Por que usar:** Mais estável, melhor suporte iOS 18+
- **Custo:** GRATUITO (com Apple ID pessoal)

#### Como usar:
```
1. Baixe e instale Sideloadly
2. Conecte iPhone via USB
3. Arraste o TarTV-iOS18-OPTIMIZED.ipa
4. Digite seu Apple ID (não precisa ser developer)
5. Aguarde instalação (5-10 min)
6. Vá em Ajustes > Geral > Gerenciamento do Dispositivo
7. Confie no seu Apple ID
```

### 2. **AltStore** 🥈
- **Download:** https://altstore.io
- **Problema comum:** Precisa de AltServer rodando no PC/Mac constantemente
- **Solução:** Certifique-se que AltServer está ativo antes de instalar

#### Como usar:
```
1. Instale AltServer no PC/Mac
2. Instale AltStore no iPhone via Wi-Fi
3. Abra AltStore > + > TarTV-iOS18-OPTIMIZED.ipa
4. Aguarde instalação
5. Confie no certificado em Ajustes
```

### 3. **3uTools** 🥉
- **Download:** http://www.3u.com
- **Vantagem:** Interface simples
- **Desvantagem:** Às vezes não funciona com iOS mais novos

---

## 🚨 SOLUÇÕES para Problemas Específicos

### ❌ "App abre e fecha imediatamente"

**Causa:** Certificado não confiável ou Info.plist com problemas

**Solução:**
1. Vá em **Ajustes > Geral > Gerenciamento do Dispositivo**
2. Toque no seu Apple ID
3. Toque em **"Confiar em [seu email]"**
4. Reinicie o iPhone
5. Tente abrir o app novamente

### ❌ "Guru Meditation" ou "Sideloading failed"

**Causa:** Cache corrompido ou conflito de certificados

**Solução:**
1. Desinstale o app antigo completamente
2. Reinicie o iPhone
3. Use o **TarTV-iOS18-OPTIMIZED.ipa** (novo)
4. Certifique-se de usar o Apple ID correto
5. Se persistir, tente outro computador

### ❌ "The URL to download the Developer disk image could not be determined"

**Causa:** Sideloadly/AltStore desatualizado

**Solução:**
1. Atualize o Sideloadly para versão mais recente
2. Se não funcionar, use 3uTools como alternativa
3. Certifique-se que está usando USB original da Apple

---

## 🔐 Certificados e Renovação

### ⏰ Renovação Automática (7 dias):
- **AltStore:** Renova automaticamente se AltServer estiver rodando
- **Sideloadly:** Precisa reinstalar manualmente a cada 7 dias

### 💡 Dica para durar mais tempo:
1. Use sempre o mesmo Apple ID
2. Não instale muitos apps sideload simultâneos (máximo 3)
3. Deixe o AltServer sempre rodando (se usar AltStore)

---

## 📋 CHECKLIST de Instalação

### Antes de começar:
- [ ] iPhone desbloqueado e conectado
- [ ] iTunes/Finder reconhece o dispositivo
- [ ] Cable USB oficial ou certificado MFi
- [ ] iOS 12.0+ (seu iOS 18.6.2 é compatível)

### Durante a instalação:
- [ ] Feche outros apps de sideload
- [ ] Mantenha iPhone desbloqueado
- [ ] Não desconecte USB durante processo
- [ ] Digite Apple ID corretamente (sem erro)

### Após instalação:
- [ ] Confie no certificado em Ajustes
- [ ] Reinicie iPhone uma vez
- [ ] Teste se app abre corretamente
- [ ] Configure suas playlists IPTV

---

## 🆘 Se NADA Funcionar - Alternativas

### 1. **TrollStore** (Se tiver jailbreak)
- Instala IPAs permanentemente (sem renovar a cada 7 dias)
- Funciona em iOS 14.0 - 16.6.1 (não iOS 18)

### 2. **Usar Simulador iOS** (Mac apenas)
- Xcode > Simulator
- Arraste o IPA para o simulador

### 3. **Build a partir do código**
- Clone este repositório
- Abra no Xcode
- Build and Run (precisa Mac + Xcode)

---

## 🎯 TESTE RÁPIDO - 2 Minutos

1. **Baixe:** TarTV-iOS18-OPTIMIZED.ipa (desta pasta)
2. **Use:** Sideloadly (mais fácil)
3. **Instale:** Arraste IPA para Sideloadly
4. **Confie:** Ajustes > Geral > Gerenciamento do Dispositivo
5. **Teste:** Abra o app

Se não funcionar em 2 minutos, o problema é específico do seu dispositivo/setup.

---

## 📞 Suporte Adicional

Se ainda tiver problemas, me informe:
1. Qual ferramenta usou (Sideloadly/AltStore/etc)
2. Qual IPA testou
3. Mensagem de erro exata
4. iOS version exato (18.6.2 confirmado)

**Arquivos criados/atualizados:**
- ✅ `Info.plist` corrigido para iOS 18+
- ✅ `TarTV-iOS18-OPTIMIZED.ipa` novo arquivo otimizado
- ✅ Scripts de build atualizados