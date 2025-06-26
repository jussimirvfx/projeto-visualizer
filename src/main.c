#include <libdragon.h>
#include <malloc.h>
#include <math.h>
#include <string.h>
#include "config.h"
#include "audio.h"
#include "intensidade-intro-mono-44100_data.h"

// Screen dimensions
#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240

// Audio settings
#define AUDIO_FREQ 22050
#define SAMPLES 512

// Colors (RGB565 format)
#define COLOR_PURPLE    0x801F  // Roxo neon
#define COLOR_PINK      0xF81F  // Rosa neon  
#define COLOR_TEAL      0x07FF  // Teal blue neon
#define COLOR_BLACK     0x0000

// Visualizer settings
#define NUM_BARS 64
#define BAR_WIDTH (SCREEN_WIDTH / NUM_BARS)
#define MAX_BAR_HEIGHT (SCREEN_HEIGHT - 40)

typedef struct {
    float real;
    float imag;
} complex_t;

// Global variables
static surface_t *disp = 0;
static float bar_heights[NUM_BARS];
static float bar_velocities[NUM_BARS];
static uint32_t frame_counter = 0;
static audio_track_t music_track;
static float frequency_data[NUM_FREQUENCY_BINS];

// Function prototypes
void process_audio(void);
void render_visualizer(void);
uint16_t get_neon_color(int bar_index, float intensity);
void draw_neon_line(int x1, int y1, int x2, int y2, uint16_t color);
void init_visualizer(void);

// Initialize the visualizer
void init_visualizer(void) {
    // Initialize visualization data
    memset(bar_heights, 0, sizeof(bar_heights));
    memset(bar_velocities, 0, sizeof(bar_velocities));
    memset(frequency_data, 0, sizeof(frequency_data));
    frame_counter = 0;
    
    // Initialize audio track with embedded data
    music_track.samples = (int16_t*)intensidade_audio;
    music_track.length = AUDIO_LENGTH;
    music_track.position = 0;
    music_track.playing = 1;  // Start playing immediately
    
    #if DEBUG_ENABLED
    debugf("Visualizer initialized\n");
    debugf("- Bars: %d\n", NUM_BARS);
    debugf("- Screen: %dx%d\n", SCREEN_WIDTH, SCREEN_HEIGHT);
    debugf("- Max height: %d\n", MAX_BAR_HEIGHT);
    debugf("- Audio length: %d samples\n", music_track.length);
    debugf("- Audio duration: %d ms\n", AUDIO_DURATION_MS);
    #endif
}

// Process audio data and update visualization
void process_audio(void) {
    // Get frequency data from real audio
    audio_update(&music_track, frequency_data);
    
    // Update visualization bars based on frequency data
    for (int i = 0; i < NUM_BARS && i < NUM_FREQUENCY_BINS; i++) {
        // Scale frequency data to bar height
        float target_height = frequency_data[i] * MAX_BAR_HEIGHT * 2.0f; // Boost amplitude
        
        // Apply some smoothing and dynamics
        float time_factor = sinf(frame_counter * 0.02f + i * 0.1f) * 0.1f + 1.0f;
        target_height *= time_factor;
        
        // Smooth animation with improved physics
        float diff = target_height - bar_heights[i];
        bar_velocities[i] += diff * RESPONSE_SPEED;
        bar_velocities[i] *= DAMPING_FACTOR;
        bar_heights[i] += bar_velocities[i];
        
        // Clamp values
        bar_heights[i] = CLAMP(bar_heights[i], MIN_BAR_HEIGHT, MAX_BAR_HEIGHT);
    }
}

// Get neon color based on frequency and intensity
uint16_t get_neon_color(int bar_index, float intensity) {
    // Create color cycling effect based on music
    float phase = (float)bar_index / NUM_BARS + frame_counter * 0.02f;
    float cycle = sinf(phase * 3.14159f * 2.0f) * 0.5f + 0.5f;
    
    // Add audio-reactive color changes
    float audio_influence = 0.0f;
    if (bar_index < NUM_FREQUENCY_BINS) {
        audio_influence = frequency_data[bar_index] * 2.0f;
    }
    
    // Combine intensity with audio data
    float total_intensity = (intensity + audio_influence) * 0.5f;
    
    // Choose color based on intensity and position
    if (total_intensity < INTENSITY_LOW_THRESHOLD) {
        return COLOR_TEAL;
    } else if (total_intensity < INTENSITY_HIGH_THRESHOLD) {
        // Blend between teal and purple based on cycle and audio
        return (cycle + audio_influence) > 0.5f ? COLOR_PURPLE : COLOR_TEAL;
    } else {
        // High intensity - use pink or purple based on cycle and audio
        return (cycle + audio_influence) > 0.3f ? COLOR_PINK : COLOR_PURPLE;
    }
}

// Draw a glowing line with neon effect
void draw_neon_line(int x1, int y1, int x2, int y2, uint16_t color) {
    // Draw main line
    graphics_draw_line(disp, x1, y1, x2, y2, color);
    
    #if GLOW_ENABLED
    // Add glow effect by drawing additional lines
    if (x1 > 0 && x2 > 0) {
        graphics_draw_line(disp, x1-1, y1, x2-1, y2, color);
    }
    if (x1 < SCREEN_WIDTH-1 && x2 < SCREEN_WIDTH-1) {
        graphics_draw_line(disp, x1+1, y1, x2+1, y2, color);
    }
    if (y1 > 0 && y2 > 0) {
        graphics_draw_line(disp, x1, y1-1, x2, y2-1, color);
    }
    if (y1 < SCREEN_HEIGHT-1 && y2 < SCREEN_HEIGHT-1) {
        graphics_draw_line(disp, x1, y1+1, x2, y2+1, color);
    }
    #endif
}

// Render the visualizer
void render_visualizer(void) {
    // Clear screen
    graphics_fill_screen(disp, COLOR_BLACK);
    
    // Calculate average intensity for background effects
    float avg_intensity = 0.0f;
    for (int i = 0; i < NUM_FREQUENCY_BINS; i++) {
        avg_intensity += frequency_data[i];
    }
    avg_intensity /= NUM_FREQUENCY_BINS;
    
    // Draw frequency bars as neon lines
    for (int i = 0; i < NUM_BARS; i++) {
        int x = i * BAR_WIDTH + BAR_WIDTH / 2;
        float intensity = bar_heights[i] / MAX_BAR_HEIGHT;
        int height = (int)bar_heights[i];
        
        uint16_t color = get_neon_color(i, intensity);
        
        // Draw symmetrical bars (up and down from center)
        int top_y = CENTER_Y - height / 2;
        int bottom_y = CENTER_Y + height / 2;
        
        // Draw main bar
        draw_neon_line(x, top_y, x, bottom_y, color);
        
        #if FLOW_LINES_ENABLED
        // Add connecting lines for flow effect
        if (i > 0) {
            int prev_x = (i-1) * BAR_WIDTH + BAR_WIDTH / 2;
            int prev_height = (int)bar_heights[i-1];
            int prev_top_y = CENTER_Y - prev_height / 2;
            int prev_bottom_y = CENTER_Y + prev_height / 2;
            
            // Connect tops and bottoms with flowing lines
            graphics_draw_line(disp, prev_x, prev_top_y, x, top_y, color);
            graphics_draw_line(disp, prev_x, prev_bottom_y, x, bottom_y, color);
        }
        #endif
    }
    
    #if CENTER_LINE_ENABLED
    // Add center line with audio reactivity
    uint16_t center_color = avg_intensity > 0.5f ? COLOR_PINK : COLOR_TEAL;
    graphics_draw_line(disp, 0, CENTER_Y, SCREEN_WIDTH, CENTER_Y, center_color);
    #endif
    
    #if TITLE_ENABLED
    // Title
    graphics_set_color(COLOR_PINK, COLOR_BLACK);
    graphics_draw_text(disp, 10, 10, "N64 MUSIC VISUALIZER");
    
    // Show track info
    graphics_set_color(COLOR_TEAL, COLOR_BLACK);
    graphics_draw_text(disp, 10, 25, "Intensidade Intro");
    #endif
    
    // Show audio progress
    float progress = (float)music_track.position / music_track.length;
    int progress_width = (int)(progress * (SCREEN_WIDTH - 20));
    graphics_draw_line(disp, 10, SCREEN_HEIGHT - 10, 10 + progress_width, SCREEN_HEIGHT - 10, COLOR_PURPLE);
    
    #if SHOW_FPS
    // Show frame counter and audio info
    char debug_text[64];
    sprintf(debug_text, "Frame: %lu | Pos: %d/%d", frame_counter, music_track.position, music_track.length);
    graphics_set_color(COLOR_WHITE, COLOR_BLACK);
    graphics_draw_text(disp, 10, SCREEN_HEIGHT - 30, debug_text);
    
    // Show frequency data peak
    float max_freq = 0.0f;
    for (int i = 0; i < NUM_FREQUENCY_BINS; i++) {
        if (frequency_data[i] > max_freq) max_freq = frequency_data[i];
    }
    sprintf(debug_text, "Peak: %.2f | Avg: %.2f", max_freq, avg_intensity);
    graphics_draw_text(disp, 10, SCREEN_HEIGHT - 45, debug_text);
    #endif
}

int main(void) {
    #if DEBUG_ENABLED
    // Initialize debug output
    debug_init_isviewer();
    debug_init_usblog();
    debugf("N64 Music Visualizer Starting...\n");
    #endif
    
    // Initialize display
    display_init(RESOLUTION_320x240, DEPTH_16_BPP, 2, GAMMA_NONE, ANTIALIAS_RESAMPLE);
    
    // Initialize graphics
    graphics_init();
    
    // Initialize audio system
    visualizer_audio_init();
    fft_init();
    
    // Initialize visualizer
    init_visualizer();
    
    #if DEBUG_ENABLED
    debugf("N64 Music Visualizer Started!\n");
    debugf("Configuration:\n");
    debugf("- Target FPS: %d\n", TARGET_FPS);
    debugf("- Glow: %s\n", GLOW_ENABLED ? "ON" : "OFF");
    debugf("- Flow lines: %s\n", FLOW_LINES_ENABLED ? "ON" : "OFF");
    debugf("- Real audio: YES\n");
    debugf("- Track: Intensidade Intro (%d samples)\n", AUDIO_LENGTH);
    #endif
    
    // Main loop
    while (1) {
        // Wait for display
        while (!(disp = display_lock()));
        
        // Process audio and update visualization
        process_audio();
        
        // Render
        render_visualizer();
        
        // Update frame counter
        frame_counter++;
        
        // Display
        display_show(disp);
        
        #if VSYNC_ENABLED
        // Simple frame rate limiting (not perfect but helps)
        // In a real implementation, you'd use timer interrupts
        for (volatile int i = 0; i < 1000; i++);
        #endif
    }
    
    return 0;
} 