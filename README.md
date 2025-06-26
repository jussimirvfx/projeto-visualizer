# N64 Music Visualizer

Um visualizer de música para Nintendo 64 desenvolvido com libdragon, criado para rodar em ED64 numa TV CRT.

## Características

- 🎵 Visualização em tempo real com efeitos neon
- 🌈 Cores vibrantes: roxo, rosa e teal blue
- 📺 Otimizado para TV CRT (320x240)
- 🎮 Compatível com ED64
- ✨ Efeitos de glow e animações suaves

## Pré-requisitos

### 1. Instalar libdragon

```bash
# Clone o libdragon
git clone https://github.com/DragonMinded/libdragon.git
cd libdragon

# Instale as dependências (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install build-essential cmake git libpng-dev

# Para macOS
brew install cmake libpng

# Build e install
./build.sh
sudo ./install.sh
```

### 2. Configurar variáveis de ambiente

Adicione ao seu `.bashrc` ou `.zshrc`:

```bash
export N64_INST=/opt/libdragon
export PATH=$PATH:$N64_INST/bin
```

## Compilação

```bash
# Compile o projeto
make

# Limpar build
make clean
```

O arquivo ROM será gerado em: `build/visualizer.z64`

## Como usar

1. **Copie o arquivo ROM para o ED64**: 
   - Copie `build/visualizer.z64` para o cartão SD do ED64

2. **Execute no N64**:
   - Insira o ED64 no N64
   - Ligue o console
   - Navegue até o arquivo e execute

## Características do Visualizer

### Cores Neon
- **Teal Blue**: Frequências baixas
- **Roxo**: Frequências médias  
- **Rosa**: Frequências altas

### Controles
- O visualizer roda automaticamente
- Pressione Reset no console para reiniciar

## Estrutura do Projeto

```
projeto-visualizer/
├── src/
│   └── main.c          # Código principal do visualizer
├── build/              # Arquivos compilados
├── Makefile           # Configuração de build
└── README.md          # Este arquivo
```

## Desenvolvimento

### Modificar cores
Edite as constantes em `src/main.c`:
```c
#define COLOR_PURPLE    0x801F  // Roxo neon
#define COLOR_PINK      0xF81F  // Rosa neon  
#define COLOR_TEAL      0x07FF  // Teal blue neon
```

### Ajustar visualização
- `NUM_BARS`: Número de barras de frequência
- `MAX_BAR_HEIGHT`: Altura máxima das barras
- Animação e física nas funções `process_audio()` e `render_visualizer()`

## Solução de Problemas

### Erro de compilação
- Verifique se o libdragon está instalado corretamente
- Confirme as variáveis de ambiente `N64_INST`

### ROM não executa no ED64
- Verifique se o arquivo `.z64` foi copiado corretamente
- Teste em um emulador primeiro (Project64, Mupen64Plus)

### Performance
- O visualizer está otimizado para 60 FPS
- Se houver problemas, reduza `NUM_BARS` ou simplifique os efeitos

## Próximos Passos

Para uma versão mais avançada, considere:
- [ ] Captura de áudio real via entrada de linha
- [ ] FFT mais sofisticada
- [ ] Mais efeitos visuais
- [ ] Interface de configuração
- [ ] Suporte a diferentes modos de vídeo

## Recursos

- [Libdragon Documentation](https://libdragon.dev/)
- [N64 Homebrew Community](https://discord.gg/WqFgNWf)
- [ED64 Documentation](https://krikzz.com/store/home/55-everdrive-64-x7.html)

---

Desenvolvido para a comunidade homebrew do N64! 🎮✨ 