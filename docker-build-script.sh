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
