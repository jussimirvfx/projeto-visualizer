# Customização Avançada do N64 Music Visualizer

Este guia explica como personalizar e modificar o visualizer para suas necessidades específicas.

## 🎨 Personalização de Cores

### Definindo Novas Cores (RGB565)

Para criar suas próprias cores neon, edite `src/config.h`:

```c
// Exemplo de cores customizadas
#define COLOR_CYAN      0x07FF  // Ciano brilhante
#define COLOR_ORANGE    0xFD20  // Laranja neon
#define COLOR_GREEN     0x07E0  // Verde neon
#define COLOR_YELLOW    0xFFE0  // Amarelo brilhante
#define COLOR_RED       0xF800  // Vermelho intenso
```

### Calculadora RGB565

Para converter RGB para RGB565:
```
RGB565 = ((R >> 3) << 11) | ((G >> 2) << 5) | (B >> 3)
```

Onde R, G, B são valores de 0-255.

### Esquemas de Cores Predefinidos

#### Esquema Cyberpunk
```c
#define COLOR_PURPLE    0x8010  // Roxo escuro
#define COLOR_PINK      0xF81F  // Rosa neon
#define COLOR_TEAL      0x0410  // Azul cibernético
```

#### Esquema Retro Wave
```c
#define COLOR_PURPLE    0x801F  // Roxo vibrante
#define COLOR_PINK      0xFC0E  // Rosa hot
#define COLOR_TEAL      0x051F  // Azul elétrico
```

#### Esquema Ocean
```c
#define COLOR_PURPLE    0x4010  // Azul profundo
#define COLOR_PINK      0x041F  // Azul claro
#define COLOR_TEAL      0x0600  // Verde oceano
```

## ⚡ Configurações de Performance

### Otimização para TV CRT

```c
// Para TVs CRT antigas (melhor compatibilidade)
#define NUM_BARS                32      // Menos barras
#define GLOW_ENABLED            0       // Desativar glow
#define VSYNC_ENABLED           1       // Manter VSync

// Para TVs CRT de qualidade (mais efeitos)
#define NUM_BARS                64      // Barras normais
#define GLOW_ENABLED            1       // Ativar glow
#define FLOW_LINES_ENABLED      1       // Linhas de conexão
```

### Configurações para ED64

```c
// Para melhor performance no ED64
#define TARGET_FPS              30      // 30 FPS mais estável
#define DEBUG_ENABLED           0       // Desativar debug
```

## 🎵 Configurações de Áudio

### Simulação de Diferentes Estilos Musicais

Edite a função `process_audio()` em `src/main.c`:

#### Para Música Eletrônica
```c
// Enfatizar frequências altas e médias
float bass = sinf(time * 0.3f + freq * 1.5f) * 0.2f + 0.2f;
float mid = sinf(time * 1.2f + freq * 10.0f) * 0.4f + 0.4f;
float treble = cosf(time * 2.0f + freq * 20.0f) * 0.4f + 0.4f;
```

#### Para Rock/Metal
```c
// Enfatizar frequências baixas e altas
float bass = sinf(time * 0.8f + freq * 3.0f) * 0.5f + 0.5f;
float mid = sinf(time * 0.9f + freq * 6.0f) * 0.2f + 0.2f;
float treble = cosf(time * 1.5f + freq * 15.0f) * 0.3f + 0.3f;
```

#### Para Música Clássica
```c
// Movimento mais suave e orgânico
float bass = sinf(time * 0.4f + freq * 2.0f) * 0.3f + 0.3f;
float mid = sinf(time * 0.6f + freq * 5.0f) * 0.4f + 0.4f;
float treble = cosf(time * 0.8f + freq * 8.0f) * 0.3f + 0.3f;
```

## 🔧 Modificações Avançadas

### Adicionando Novos Efeitos Visuais

#### Efeito Particles
```c
// Em render_visualizer(), adicione:
for (int i = 0; i < NUM_BARS; i++) {
    if (bar_heights[i] > MAX_BAR_HEIGHT * 0.8f) {
        // Desenhar "faíscas" no topo das barras altas
        int spark_x = i * BAR_WIDTH + (rand() % BAR_WIDTH);
        int spark_y = CENTER_Y - bar_heights[i]/2 + (rand() % 10 - 5);
        graphics_draw_pixel(disp, spark_x, spark_y, COLOR_WHITE);
    }
}
```

#### Efeito Wave
```c
// Criar ondas que se propagam
float wave_offset = sinf(frame_counter * 0.1f) * 20.0f;
for (int i = 0; i < SCREEN_WIDTH; i++) {
    int wave_y = CENTER_Y + sinf(i * 0.1f + frame_counter * 0.05f) * wave_offset;
    graphics_draw_pixel(disp, i, wave_y, COLOR_TEAL);
}
```

### Modos de Visualização Alternativos

#### Modo Circular
```c
void render_circular_visualizer(void) {
    int center_x = SCREEN_WIDTH / 2;
    int center_y = SCREEN_HEIGHT / 2;
    
    for (int i = 0; i < NUM_BARS; i++) {
        float angle = (float)i / NUM_BARS * 2.0f * M_PI;
        int radius = 50 + (int)bar_heights[i];
        
        int x = center_x + cos(angle) * radius;
        int y = center_y + sin(angle) * radius;
        
        draw_neon_line(center_x, center_y, x, y, get_neon_color(i, bar_heights[i] / MAX_BAR_HEIGHT));
    }
}
```

#### Modo Espectro 3D (Pseudo-3D)
```c
void render_3d_spectrum(void) {
    for (int i = 0; i < NUM_BARS; i++) {
        int x = i * BAR_WIDTH;
        int height = (int)bar_heights[i];
        
        // Simular profundidade
        int depth_offset = i / 4;
        
        // Desenhar "face frontal"
        draw_neon_line(x, CENTER_Y - height/2, x, CENTER_Y + height/2, get_neon_color(i, bar_heights[i] / MAX_BAR_HEIGHT));
        
        // Desenhar "face lateral" para efeito 3D
        if (i < NUM_BARS - 1) {
            draw_neon_line(x + depth_offset, CENTER_Y - height/2 - depth_offset, 
                          x + depth_offset, CENTER_Y + height/2 - depth_offset, 
                          get_neon_color(i, bar_heights[i] / MAX_BAR_HEIGHT * 0.7f));
        }
    }
}
```

## 🎮 Controles (Para Implementação Futura)

### Adicionando Controle do Usuário

```c
// No main loop, adicione verificação de controle
void check_controller_input(void) {
    controller_scan();
    struct controller_data keys_pressed = get_keys_pressed();
    
    if (keys_pressed.c[0].A) {
        // Alternar modo de visualização
        visualization_mode = (visualization_mode + 1) % 3;
    }
    
    if (keys_pressed.c[0].B) {
        // Alternar esquema de cores
        color_scheme = (color_scheme + 1) % 4;
    }
    
    if (keys_pressed.c[0].C_up) {
        // Aumentar sensibilidade
        sensitivity = MIN(sensitivity + 0.1f, 2.0f);
    }
    
    if (keys_pressed.c[0].C_down) {
        // Diminuir sensibilidade
        sensitivity = MAX(sensitivity - 0.1f, 0.1f);
    }
}
```

## 📊 Debug e Profiling

### Medindo Performance

```c
// Adicione no main loop para medir FPS real
static uint32_t last_time = 0;
static uint32_t frame_count = 0;

uint32_t current_time = get_ticks();
frame_count++;

if (current_time - last_time >= TICKS_PER_SECOND) {
    debugf("FPS: %lu\n", frame_count);
    frame_count = 0;
    last_time = current_time;
}
```

### Visualização de Debug

```c
#if DEBUG_ENABLED
void draw_debug_info(void) {
    char debug_text[64];
    
    // Mostrar altura máxima atual
    float max_height = 0;
    for (int i = 0; i < NUM_BARS; i++) {
        if (bar_heights[i] > max_height) max_height = bar_heights[i];
    }
    
    sprintf(debug_text, "Max: %.1f", max_height);
    graphics_set_color(COLOR_WHITE, COLOR_BLACK);
    graphics_draw_text(disp, SCREEN_WIDTH - 100, 10, debug_text);
}
#endif
```

## 🔄 Compilação Personalizada

### Makefile Personalizado

Crie diferentes targets para diferentes configurações:

```makefile
# Versão de alta performance
perf:
	$(N64_CC) $(N64_CFLAGS) -DNUM_BARS=32 -DGLOW_ENABLED=0 -O3 src/main.c -o $(BUILD_DIR)/visualizer_perf.z64

# Versão com todos os efeitos
full:
	$(N64_CC) $(N64_CFLAGS) -DNUM_BARS=64 -DGLOW_ENABLED=1 -DFLOW_LINES_ENABLED=1 -O2 src/main.c -o $(BUILD_DIR)/visualizer_full.z64

# Versão debug
debug:
	$(N64_CC) $(N64_CFLAGS) -DDEBUG_ENABLED=1 -DSHOW_FPS=1 -O0 -g src/main.c -o $(BUILD_DIR)/visualizer_debug.z64
```

## 🎯 Tips para TV CRT

### Otimizações para CRT

1. **Use cores saturadas**: CRTs respondem bem a cores vibrantes
2. **Evite linhas muito finas**: Podem não aparecer bem na CRT
3. **Prefira movimento suave**: CRTs têm melhor motion blur natural
4. **Teste em resolução nativa**: 320x240 é ideal para N64

### Configuração Ideal para CRT

```c
// config.h otimizado para CRT
#define NUM_BARS                48      // Boa visibilidade
#define GLOW_ENABLED            1       // CRT naturalmente "glow"
#define FLOW_LINES_ENABLED      1       // Movimento suave
#define CENTER_LINE_ENABLED     0       // Evitar linhas horizontais fixas
```

---

**Dica**: Sempre teste suas modificações em emulador primeiro, depois teste no hardware real. O ED64 pode ter comportamentos ligeiramente diferentes do emulador! 