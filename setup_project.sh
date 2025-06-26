#!/bin/bash

# Setup completo do N64 Music Visualizer
# Este script automatiza todo o processo de preparação e compilação

set -e

echo "🎮 N64 Music Visualizer - Setup Completo"
echo "========================================"

# Verificar se Python está disponível
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado!"
    echo "   Instale Python 3 primeiro."
    exit 1
fi

echo "✅ Python 3 encontrado"

# Verificar se libdragon está configurado
if [ -z "$N64_INST" ]; then
    echo "⚠️  Libdragon não configurado!"
    echo ""
    echo "Opções:"
    echo "1. Instalar libdragon automaticamente"
    echo "2. Configurar manualmente"
    echo "3. Cancelar"
    echo ""
    read -p "Escolha (1-3): " -n 1 -r choice
    echo ""
    
    case $choice in
        1)
            echo "🔧 Instalando libdragon..."
            if [ -f "install_libdragon.sh" ]; then
                ./install_libdragon.sh
                echo ""
                echo "⚠️  Configure as variáveis de ambiente:"
                echo "export N64_INST=/opt/libdragon"
                echo "export PATH=\$PATH:\$N64_INST/bin"
                echo ""
                echo "Execute: source ~/.bashrc (ou ~/.zshrc)"
                echo "Depois execute este script novamente."
                exit 0
            else
                echo "❌ Script de instalação não encontrado!"
                exit 1
            fi
            ;;
        2)
            echo "📋 Para configurar manualmente:"
            echo "1. Instale libdragon: https://libdragon.dev/"
            echo "2. Configure: export N64_INST=/opt/libdragon"
            echo "3. Configure: export PATH=\$PATH:\$N64_INST/bin"
            exit 0
            ;;
        3)
            echo "❌ Setup cancelado"
            exit 0
            ;;
        *)
            echo "❌ Opção inválida"
            exit 1
            ;;
    esac
fi

echo "✅ Libdragon configurado em: $N64_INST"

# Verificar se o arquivo de áudio existe
AUDIO_FILE="intensidade-intro-mono-44100.wav"
if [ ! -f "$AUDIO_FILE" ]; then
    echo "❌ Arquivo de áudio não encontrado: $AUDIO_FILE"
    echo "   Certifique-se de que o arquivo está no diretório do projeto."
    exit 1
fi

echo "✅ Arquivo de áudio encontrado: $AUDIO_FILE"

# Converter áudio para dados C (se necessário)
AUDIO_DATA_FILE="src/intensidade-intro-mono-44100_data.c"
if [ ! -f "$AUDIO_DATA_FILE" ] || [ "$AUDIO_FILE" -nt "$AUDIO_DATA_FILE" ]; then
    echo "🎵 Convertendo áudio para dados C..."
    
    # Criar diretório tools se não existir
    mkdir -p tools
    
    if [ -f "tools/wav_to_c.py" ]; then
        python3 tools/wav_to_c.py "$AUDIO_FILE" intensidade_audio
        echo "✅ Áudio convertido com sucesso!"
    else
        echo "❌ Conversor de áudio não encontrado!"
        exit 1
    fi
else
    echo "✅ Dados de áudio já estão atualizados"
fi

# Verificar se todos os arquivos fonte existem
REQUIRED_FILES=(
    "src/main.c"
    "src/config.h"
    "src/audio.h"
    "src/audio.c"
    "src/intensidade-intro-mono-44100_data.c"
    "src/intensidade-intro-mono-44100_data.h"
    "Makefile"
)

echo "🔍 Verificando arquivos do projeto..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Arquivo obrigatório não encontrado: $file"
        exit 1
    fi
done
echo "✅ Todos os arquivos necessários estão presentes"

# Verificar ferramentas de compilação
if ! command -v mips64-elf-gcc &> /dev/null; then
    echo "❌ Compilador MIPS não encontrado!"
    echo "   Verifique se libdragon foi instalado corretamente."
    exit 1
fi

echo "✅ Compilador MIPS encontrado"

# Escolher configuração de build
echo ""
echo "🔧 Configurações de Build Disponíveis:"
echo "1. debug    - Debug completo com informações na tela"
echo "2. full     - Versão completa com todos os efeitos"
echo "3. performance - Versão otimizada para melhor performance"
echo "4. default  - Configuração padrão balanceada"
echo ""
read -p "Escolha a configuração (1-4): " -n 1 -r build_choice
echo ""

case $build_choice in
    1)
        BUILD_TARGET="debug"
        echo "🐛 Compilando versão debug..."
        ;;
    2)
        BUILD_TARGET="full"
        echo "✨ Compilando versão completa..."
        ;;
    3)
        BUILD_TARGET="performance"
        echo "⚡ Compilando versão otimizada..."
        ;;
    4|"")
        BUILD_TARGET=""
        echo "⚖️  Compilando versão padrão..."
        ;;
    *)
        echo "❌ Opção inválida, usando configuração padrão"
        BUILD_TARGET=""
        ;;
esac

# Compilar projeto
echo "🔨 Compilando o projeto..."
make clean

if [ -z "$BUILD_TARGET" ]; then
    make
else
    make $BUILD_TARGET
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 COMPILAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "=================================="
    echo ""
    echo "📁 ROM gerada: build/visualizer.z64"
    echo "📊 Informações do áudio:"
    echo "   - Arquivo: $AUDIO_FILE"
    echo "   - Configuração: $(python3 -c "import wave; w=wave.open('$AUDIO_FILE','rb'); print(f'{w.getnframes()} samples, {w.getnframes()/w.getframerate():.1f}s')")"
    echo ""
    echo "📋 PRÓXIMOS PASSOS:"
    echo "=================="
    echo "1. 💾 Copie build/visualizer.z64 para o cartão SD do ED64"
    echo "2. 🎮 Insira o ED64 no Nintendo 64"
    echo "3. 📺 Ligue o N64 conectado na TV CRT"
    echo "4. 🎵 Execute o visualizer e aproveite!"
    echo ""
    echo "🧪 Para testar em emulador:"
    echo "   project64 build/visualizer.z64"
    echo "   mupen64plus build/visualizer.z64"
    echo ""
    echo "🎨 Para personalizar:"
    echo "   - Edite src/config.h para mudar cores e configurações"
    echo "   - Veja CUSTOMIZATION.md para modificações avançadas"
    echo ""
    echo "🔄 Para recompilar após mudanças:"
    echo "   make clean && make"
    
    # Mostrar tamanho da ROM
    ROM_SIZE=$(stat -f%z build/visualizer.z64 2>/dev/null || stat -c%s build/visualizer.z64 2>/dev/null || echo "unknown")
    if [ "$ROM_SIZE" != "unknown" ]; then
        ROM_SIZE_MB=$(echo "scale=2; $ROM_SIZE / 1024 / 1024" | bc)
        echo ""
        echo "📏 Tamanho da ROM: ${ROM_SIZE_MB}MB"
    fi
    
else
    echo ""
    echo "❌ ERRO NA COMPILAÇÃO!"
    echo "====================="
    echo ""
    echo "Verifique:"
    echo "- Se libdragon está instalado corretamente"
    echo "- Se todas as variáveis de ambiente estão configuradas"
    echo "- Se todos os arquivos fonte estão presentes"
    echo ""
    echo "Para debug, tente:"
    echo "   make clean"
    echo "   make debug"
    exit 1
fi 