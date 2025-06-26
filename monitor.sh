#!/bin/bash

while true; do
    clear
    echo "🔍 Monitor Libdragon Build - $(date)"
    echo "======================================="
    
    # Verificar processos
    PROCESSES=$(ps aux | grep "build-toolchain" | grep -v grep | wc -l | tr -d ' ')
    echo "📊 Processos ativos: $PROCESSES"
    
    if [ "$PROCESSES" -gt 0 ]; then
        echo "✅ Build em andamento..."
        
        # Tamanho do log
        if [ -f ~/libdragon-build.log ]; then
            LOG_SIZE=$(wc -c ~/libdragon-build.log 2>/dev/null | awk '{print $1}')
            echo "📁 Log size: $LOG_SIZE bytes"
            
            echo "\n📋 Últimas 5 linhas:"
            tail -5 ~/libdragon-build.log 2>/dev/null | sed 's/^/   /'
        fi
        
        # Verificar diretórios criados
        if [ -d "/Users/jussimir/libdragon/build" ]; then
            BUILD_SIZE=$(du -sh /Users/jussimir/libdragon/build 2>/dev/null | awk '{print $1}')
            echo "\n📦 Build directory: $BUILD_SIZE"
        fi
        
    else
        echo "❌ Build parou"
        
        # Verificar se terminou com sucesso
        if [ -f "/Users/jussimir/libdragon/bin/mips64-elf-gcc" ]; then
            echo "🎉 BUILD CONCLUÍDO COM SUCESSO!"
            break
        else
            echo "⚠️  Build falhou ou foi interrompido"
            echo "📋 Últimas linhas do log:"
            tail -10 ~/libdragon-build.log 2>/dev/null | sed 's/^/   /'
            break
        fi
    fi
    
    echo "\n⏰ Atualizando em 30 segundos... (Ctrl+C para parar)"
    sleep 30
done 