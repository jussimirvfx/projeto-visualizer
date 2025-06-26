#!/bin/bash

# Script de instalação do libdragon para desenvolvimento N64
# Para usar com o Music Visualizer

set -e

echo "🎮 Instalando libdragon para desenvolvimento N64"
echo "================================================"

# Verificar sistema operacional
if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="macOS"
    echo "✅ Sistema detectado: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SYSTEM="Linux"
    echo "✅ Sistema detectado: Linux"
else
    echo "❌ Sistema não suportado: $OSTYPE"
    echo "   Este script suporta apenas macOS e Linux"
    exit 1
fi

# Verificar dependências
echo "🔍 Verificando dependências..."

if [[ "$SYSTEM" == "macOS" ]]; then
    # Verificar se o Homebrew está instalado
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew não encontrado!"
        echo "   Instale o Homebrew primeiro: https://brew.sh/"
        exit 1
    fi
    
    echo "📦 Instalando dependências via Homebrew..."
    brew install cmake libpng
    
elif [[ "$SYSTEM" == "Linux" ]]; then
    echo "📦 Instalando dependências via apt..."
    sudo apt-get update
    sudo apt-get install -y build-essential cmake git libpng-dev
fi

# Diretório de instalação
INSTALL_DIR="/opt/libdragon"
echo "📁 Diretório de instalação: $INSTALL_DIR"

# Verificar se já existe
if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Libdragon já existe em $INSTALL_DIR"
    read -p "Deseja remover e reinstalar? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removendo instalação anterior..."
        sudo rm -rf "$INSTALL_DIR"
    else
        echo "❌ Instalação cancelada"
        exit 1
    fi
fi

# Criar diretório temporário
TEMP_DIR=$(mktemp -d)
echo "📁 Usando diretório temporário: $TEMP_DIR"

cd "$TEMP_DIR"

# Clone do libdragon
echo "📥 Clonando libdragon..."
git clone https://github.com/DragonMinded/libdragon.git
cd libdragon

# Build do libdragon
echo "🔨 Compilando libdragon..."
./build.sh

# Instalação
echo "📦 Instalando libdragon..."
sudo ./install.sh

# Verificar instalação
if [ -d "$INSTALL_DIR" ]; then
    echo "✅ Libdragon instalado com sucesso!"
else
    echo "❌ Erro na instalação do libdragon"
    exit 1
fi

# Limpeza
echo "🧹 Limpando arquivos temporários..."
rm -rf "$TEMP_DIR"

# Configurar variáveis de ambiente
echo ""
echo "🔧 CONFIGURAÇÃO DO AMBIENTE"
echo "=========================="
echo ""
echo "Adicione as seguintes linhas ao seu ~/.bashrc ou ~/.zshrc:"
echo ""
echo "export N64_INST=/opt/libdragon"
echo "export PATH=\$PATH:\$N64_INST/bin"
echo ""
echo "Depois execute:"
echo "source ~/.bashrc  # ou source ~/.zshrc"
echo ""

# Testar se as ferramentas estão disponíveis
if command -v mips64-elf-gcc &> /dev/null; then
    echo "✅ Compilador MIPS encontrado!"
    echo "🎮 Você pode agora compilar o Music Visualizer com: ./build.sh"
else
    echo "⚠️  Compilador MIPS não encontrado no PATH"
    echo "   Configure as variáveis de ambiente como mostrado acima"
fi

echo ""
echo "🎉 Instalação concluída!"
echo "   Para compilar o visualizer: ./build.sh"
echo "   Para testar: copie o .z64 para o ED64" 