#!/bin/bash

# N64 Music Visualizer - Build com libdragon-docker
# Usa o container oficial da comunidade libdragon

set -e

echo "🐳 N64 Music Visualizer - Docker Build (Comunidade)"
echo "================================================="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo ""
    echo "Para instalar Docker no macOS:"
    echo "1. Baixe Docker Desktop: https://www.docker.com/products/docker-desktop"
    echo "2. Ou use Homebrew: brew install --cask docker"
    echo ""
    exit 1
fi

echo "✅ Docker encontrado"

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando!"
    echo "   Inicie o Docker Desktop e tente novamente."
    exit 1
fi

echo "✅ Docker está rodando"

# Converter áudio se necessário
AUDIO_DATA_FILE="src/intensidade-intro-mono-44100_data.c"
if [ ! -f "$AUDIO_DATA_FILE" ]; then
    echo "🎵 Convertendo áudio..."
    python3 tools/wav_to_c.py intensidade-intro-mono-44100.wav intensidade_audio
fi

echo "✅ Áudio convertido"

# Usar libdragon-docker oficial
echo "📥 Baixando container libdragon-docker..."
docker pull anacierdem/libdragon:latest

echo "🔨 Compilando ROM com libdragon-docker..."

# Criar script de build temporário
cat > docker-build-script.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 Configurando ambiente no container..."
export N64_INST=/usr/local
export PATH=$PATH:/usr/local/bin

echo "🧹 Limpando build anterior..."
make clean || true

echo "🔨 Compilando ROM..."
make

echo "📦 ROM compilada com sucesso!"
ls -la build/
EOF

chmod +x docker-build-script.sh

# Executar build no container
docker run --rm \
    -v "$(pwd)":/project \
    -w /project \
    anacierdem/libdragon:latest \
    bash docker-build-script.sh

# Limpeza
rm -f docker-build-script.sh

if [ -f "build/visualizer.z64" ]; then
    echo ""
    echo "🎉 SUCESSO! ROM compilada com Docker!"
    echo "=================================="
    echo ""
    echo "📁 ROM: build/visualizer.z64"
    
    # Mostrar tamanho
    ROM_SIZE=$(stat -f%z build/visualizer.z64 2>/dev/null || stat -c%s build/visualizer.z64 2>/dev/null || echo "unknown")
    if [ "$ROM_SIZE" != "unknown" ]; then
        ROM_SIZE_MB=$(echo "scale=2; $ROM_SIZE / 1024 / 1024" | bc 2>/dev/null || echo "N/A")
        echo "📏 Tamanho: ${ROM_SIZE_MB}MB"
    fi
    
    echo ""
    echo "📋 Próximos passos:"
    echo "1. 💾 Copie build/visualizer.z64 para o ED64"
    echo "2. 🎮 Teste no N64 ou emulador:"
    echo "   mupen64plus build/visualizer.z64"
    echo "   project64 build/visualizer.z64"
    echo ""
    echo "🎵 Seu 'Intensidade Intro' está pronto para a CRT!"
else
    echo "❌ Erro: ROM não foi gerada"
    exit 1
fi 