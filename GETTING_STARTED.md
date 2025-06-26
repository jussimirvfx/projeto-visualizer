# 🎮 Primeiros Passos - N64 Music Visualizer

Guia completo para colocar seu visualizer funcionando no Nintendo 64 com o arquivo "Intensidade Intro".

## 🚀 Setup Automático (Recomendado)

O jeito mais fácil é usar o script de setup automático:

```bash
./setup_project.sh
```

Este script vai:
- ✅ Verificar todas as dependências
- 🎵 Converter seu arquivo de áudio automaticamente
- 🔨 Compilar o projeto
- 📋 Te dar instruções finais

## 🛠️ Setup Manual (Se preferir)

### 1. Instalar Libdragon

**macOS:**
```bash
./install_libdragon.sh
```

**Configurar ambiente:**
```bash
export N64_INST=/opt/libdragon
export PATH=$PATH:$N64_INST/bin
source ~/.zshrc  # ou ~/.bashrc
```

### 2. Converter Áudio

```bash
python3 tools/wav_to_c.py intensidade-intro-mono-44100.wav intensidade_audio
```

### 3. Compilar

**Versão padrão:**
```bash
make
```

**Outras opções:**
```bash
make debug        # Com debug na tela
make full         # Todos os efeitos
make performance  # Otimizada para performance
```

## 📱 Usando no ED64

### 1. Preparar o Cartão SD
- Formate o cartão SD (FAT32)
- Copie `build/visualizer.z64` para a raiz do cartão

### 2. Configurar no N64
- Insira o ED64 no N64
- Conecte o N64 na TV CRT
- Ligue o console
- Navegue até `visualizer.z64` e execute

## 🎵 O que Esperar

### Visual
- 🌈 **Cores neon**: Roxo, rosa e teal blue
- ✨ **Efeitos**: Glow, linhas conectadas, animações suaves
- 📊 **Espectro**: 64 barras de frequência reagindo ao áudio
- 🎯 **Resolução**: 320x240 otimizada para CRT

### Áudio
- 🎼 **Música**: "Intensidade Intro" (8.8 segundos)
- 🔄 **Loop**: Toca em loop infinito
- 📈 **Análise**: FFT real do áudio
- 🎚️ **Frequências**: Graves = teal, médios = roxo, agudos = rosa

## 🧪 Testando em Emulador

Se quiser testar antes de colocar no N64 real:

**Project64:**
```bash
project64 build/visualizer.z64
```

**Mupen64Plus:**
```bash
mupen64plus build/visualizer.z64
```

**RetroArch (Mupen64Plus core):**
- Abra o RetroArch
- Carregue o core Mupen64Plus
- Abra `build/visualizer.z64`

## 📊 Informações Técnicas

### Arquivo de Áudio Atual
- **Nome**: intensidade-intro-mono-44100.wav
- **Formato**: WAV PCM 16-bit mono
- **Sample Rate**: 44100 Hz
- **Duração**: ~8.8 segundos
- **Tamanho na ROM**: ~776 KB

### Performance
- **FPS**: 60 FPS estável
- **Barras**: 64 (configurável)
- **FFT**: 512 amostras
- **Latência**: Baixíssima (tempo real)

## 🎨 Personalizando

### Cores Fáceis
Edite `src/config.h`:
```c
#define COLOR_PURPLE    0x801F  // Mude aqui
#define COLOR_PINK      0xF81F  // E aqui
#define COLOR_TEAL      0x07FF  // E aqui
```

### Performance
Para TVs CRT mais antigas:
```c
#define NUM_BARS        32      // Menos barras
#define GLOW_ENABLED    0       // Sem glow
```

### Efeitos
```c
#define GLOW_ENABLED            1  // Liga/desliga glow
#define FLOW_LINES_ENABLED      1  // Linhas de conexão
#define CENTER_LINE_ENABLED     1  // Linha central
```

## 🔧 Solução de Problemas

### "N64_INST não definido"
```bash
export N64_INST=/opt/libdragon
export PATH=$PATH:$N64_INST/bin
```

### "Python não encontrado"
- macOS: `brew install python3`
- Ubuntu: `sudo apt install python3`

### "Arquivo WAV não encontrado"
- Certifique-se que `intensidade-intro-mono-44100.wav` está na pasta do projeto

### ROM não executa no ED64
- Teste em emulador primeiro
- Verifique se o cartão SD está formatado em FAT32
- Confirme que o arquivo `.z64` foi copiado corretamente

### Performance ruim na CRT
- Use `make performance` para versão otimizada
- Reduza `NUM_BARS` em `src/config.h`
- Desative `GLOW_ENABLED`

## 📂 Estrutura Final do Projeto

```
projeto-visualizer/
├── src/
│   ├── main.c                              # Código principal
│   ├── config.h                           # Configurações
│   ├── audio.h                            # Header de áudio
│   ├── audio.c                            # Processamento de áudio
│   ├── intensidade-intro-mono-44100_data.c # Dados do áudio
│   └── intensidade-intro-mono-44100_data.h # Header dos dados
├── tools/
│   └── wav_to_c.py                        # Conversor de áudio
├── build/
│   └── visualizer.z64                     # ROM final
├── intensidade-intro-mono-44100.wav       # Seu arquivo de áudio
├── Makefile                               # Sistema de build
├── setup_project.sh                      # Setup automático
└── README.md                              # Documentação
```

## 🎯 Próximos Passos Recomendados

1. **Teste básico**: Execute `./setup_project.sh`
2. **Teste emulador**: `mupen64plus build/visualizer.z64`
3. **Copie para ED64**: `cp build/visualizer.z64 /caminho/para/cartao/sd/`
4. **Teste no N64**: Insira ED64 e execute
5. **Customize**: Edite `src/config.h` para suas preferências

## 🆘 Suporte

Se tiver problemas:
1. Verifique que todos os arquivos estão presentes
2. Teste o setup automático: `./setup_project.sh`
3. Tente compilação debug: `make debug`
4. Teste em emulador antes do hardware real

---

**Dica**: A primeira vez pode demorar um pouco por causa da conversão do áudio. Depois disso, recompilações são muito rápidas! 🚀 