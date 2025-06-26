#!/bin/bash

echo "🔍 Monitor do Build Libdragon"
echo "=============================="

# Verificar se processo está rodando
if ps aux | grep "build-toolchain" | grep -v grep > /dev/null; then
    echo "✅ Build em andamento..."
    
    # Mostrar processos relacionados
    echo -e "\n📊 Processos ativos:"
    ps aux | grep -E "(gcc|make|configure)" | grep -v grep | wc -l | xargs echo "   Processos de compilação:"
    
    # Verificar tamanho do diretório
    if [ -d "/Users/jussimir/libdragon/build" ]; then
        echo -e "\n📁 Tamanho atual do build:"
        du -sh /Users/jussimir/libdragon/build 2>/dev/null || echo "   Build directory não encontrado ainda"
    fi
    
    echo -e "\n⏰ Continue aguardando... (30-60 min)"
else
    echo "❌ Build não está rodando"
    
    # Verificar se terminou com sucesso
    if [ -f "/Users/jussimir/libdragon/bin/mips64-elf-gcc" ]; then
        echo "🎉 BUILD CONCLUÍDO COM SUCESSO!"
        echo "✅ Compilador encontrado em: /Users/jussimir/libdragon/bin/mips64-elf-gcc"
    else
        echo "⚠️  Build não encontrado - pode ter falhado"
        echo "💡 Execute novamente: ~/libdragon/src/tools/build-toolchain.sh /Users/jussimir/libdragon"
    fi
fi

echo ""
echo "🔄 Execute novamente este script para verificar progresso:"
echo "   bash ./libdragon-monitor.sh"

chmod +x monitor.sh && ./monitor.sh 