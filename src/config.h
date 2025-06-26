#ifndef CONFIG_H
#define CONFIG_H

// =============================================================================
// N64 MUSIC VISUALIZER - CONFIGURAÇÕES
// =============================================================================

// Configurações de Display
#define SCREEN_WIDTH            320
#define SCREEN_HEIGHT           240
#define CENTER_Y                (SCREEN_HEIGHT / 2)

// Configurações do Visualizer
#define NUM_BARS                64      // Número de barras de frequência
#define BAR_WIDTH               (SCREEN_WIDTH / NUM_BARS)
#define MAX_BAR_HEIGHT          (SCREEN_HEIGHT - 40)
#define MIN_BAR_HEIGHT          5

// Configurações de Animação
#define ANIMATION_SPEED         0.1f    // Velocidade base da animação
#define DAMPING_FACTOR          0.85f   // Suavização da animação (0.0-1.0)
#define RESPONSE_SPEED          0.1f    // Velocidade de resposta às mudanças

// Configurações de Cores (RGB565)
#define COLOR_PURPLE            0x801F  // Roxo neon
#define COLOR_PINK              0xF81F  // Rosa neon  
#define COLOR_TEAL              0x07FF  // Teal blue neon
#define COLOR_BLACK             0x0000  // Fundo preto
#define COLOR_WHITE             0xFFFF  // Branco (para texto)

// Limites de intensidade para cores
#define INTENSITY_LOW_THRESHOLD     0.3f    // Teal para baixas frequências
#define INTENSITY_HIGH_THRESHOLD    0.7f    // Rosa para altas frequências

// Configurações de Efeitos
#define GLOW_ENABLED            1       // Ativar efeito de glow (0/1)
#define FLOW_LINES_ENABLED      1       // Ativar linhas de conexão (0/1)
#define CENTER_LINE_ENABLED     1       // Ativar linha central (0/1)
#define TITLE_ENABLED           1       // Mostrar título (0/1)

// Configurações de Performance
#define TARGET_FPS              60      // FPS alvo
#define VSYNC_ENABLED           1       // Ativar VSync (0/1)

// Configurações de Áudio (para implementação futura)
#define AUDIO_SAMPLE_RATE       22050   // Taxa de amostragem
#define AUDIO_BUFFER_SIZE       512     // Tamanho do buffer de áudio
#define FFT_SIZE                256     // Tamanho da FFT

// Configurações de Debug
#define DEBUG_ENABLED           1       // Ativar debug (0/1)
#define SHOW_FPS                0       // Mostrar FPS na tela (0/1)

// Macros de conveniência
#define CLAMP(x, min, max)      ((x) < (min) ? (min) : ((x) > (max) ? (max) : (x)))
#define LERP(a, b, t)           ((a) + (t) * ((b) - (a)))

#endif // CONFIG_H 