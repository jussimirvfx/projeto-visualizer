#!/bin/bash

# N64 Music Visualizer Build Script
# Este script facilita a compilação do projeto

set -e

echo "🎮 N64 Music Visualizer - Build Script"
echo "======================================"

# Verificar se libdragon está instalado
if [ -z "$N64_INST" ]; then
    echo "❌ Erro: Variável N64_INST não está definida!"
    echo "   Configure o ambiente primeiro:"
    echo "   export N64_INST=/opt/libdragon"
    echo "   export PATH=\$PATH:\$N64_INST/bin"
    exit 1
fi

if [ ! -d "$N64_INST" ]; then
    echo "❌ Erro: Diretório libdragon não encontrado em $N64_INST"
    echo "   Instale o libdragon primeiro!"
    exit 1
fi

echo "✅ Libdragon encontrado em: $N64_INST"

# Verificar se as ferramentas estão disponíveis
if ! command -v mips64-elf-gcc &> /dev/null; then
    echo "❌ Erro: Compilador MIPS não encontrado!"
    echo "   Verifique se libdragon foi instalado corretamente."
    exit 1
fi

echo "✅ Compilador MIPS encontrado"

# Criar diretório build se não existir
mkdir -p build

echo "🔨 Compilando..."

# Compilar o projeto
make clean
make

if [ $? -eq 0 ]; then
    echo "✅ Compilação concluída com sucesso!"
    echo "📁 ROM gerada: build/visualizer.z64"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. Copie build/visualizer.z64 para o cartão SD do ED64"
    echo "   2. Insira o ED64 no N64 e execute o arquivo"
    echo ""
    echo "🧪 Para testar em emulador:"
    echo "   project64 build/visualizer.z64"
    echo "   mupen64plus build/visualizer.z64"
else
    echo "❌ Erro na compilação!"
    exit 1
fi 