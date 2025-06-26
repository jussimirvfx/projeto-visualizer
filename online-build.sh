#!/bin/bash

# Build online para N64 Music Visualizer
# Usa GitHub Actions para compilar sem instalar nada local

set -e

echo "☁️  N64 Music Visualizer - Build Online"
echo "======================================"

# Verificar se git está configurado
if ! git config user.name > /dev/null 2>&1; then
    echo "⚠️  Configure o git primeiro:"
    echo "git config --global user.name 'Seu Nome'"
    echo "git config --global user.email 'seu@email.com'"
    exit 1
fi

echo "✅ Git configurado"

# Converter áudio localmente
echo "🎵 Convertendo áudio..."
python3 tools/wav_to_c.py intensidade-intro-mono-22050.wav intensidade_audio

# Verificar se é um repositório git
if [ ! -d ".git" ]; then
    echo "🔧 Inicializando repositório Git..."
    git init
    git add .
    git commit -m "Initial commit - N64 Music Visualizer"
fi

echo ""
echo "📋 OPÇÕES DE BUILD ONLINE:"
echo "========================"
echo ""
echo "1. 🐙 GitHub Actions (Recomendado)"
echo "   - Faça push do código para GitHub"
echo "   - O GitHub vai compilar automaticamente"
echo "   - Download da ROM em Actions"
echo ""
echo "2. 🌐 Gitpod (Browser)"
echo "   - Abra o projeto no Gitpod"
echo "   - Compile diretamente no browser"
echo ""
echo "3. ☁️  Codespaces"
echo "   - Use GitHub Codespaces"
echo "   - Ambiente completo na nuvem"
echo ""

read -p "Quer criar o GitHub Actions? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p .github/workflows
    
cat > .github/workflows/build.yml << 'EOF'
name: Build N64 Visualizer

on: 
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential git cmake libpng-dev python3
    
    - name: Install libdragon
      run: |
        cd /opt
        sudo git clone https://github.com/DragonMinded/libdragon.git
        cd libdragon
        sudo ./build.sh
        sudo ./install.sh
    
    - name: Convert audio
      run: |
        python3 tools/wav_to_c.py intensidade-intro-mono-44100.wav intensidade_audio
    
    - name: Build ROM
      run: |
        export N64_INST=/opt/libdragon
        export PATH=$PATH:/opt/libdragon/bin
        make clean
        make
    
    - name: Upload ROM
      uses: actions/upload-artifact@v3
      with:
        name: n64-visualizer-rom
        path: build/visualizer.z64
EOF

    echo "✅ GitHub Actions criado!"
    echo ""
    echo "📋 PRÓXIMOS PASSOS:"
    echo "=================="
    echo "1. Crie um repositório no GitHub"
    echo "2. Faça push do código:"
    echo "   git remote add origin https://github.com/SEU_USUARIO/projeto-visualizer.git"
    echo "   git branch -M main"
    echo "   git add ."
    echo "   git commit -m 'Add N64 Music Visualizer'"
    echo "   git push -u origin main"
    echo ""
    echo "3. Vá na aba 'Actions' do GitHub"
    echo "4. Aguarde a compilação terminar"
    echo "5. Baixe a ROM em 'Artifacts'"
    echo ""
    echo "🎮 Depois é só copiar para o ED64!"
fi 