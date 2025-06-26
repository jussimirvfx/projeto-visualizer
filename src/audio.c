#include "audio.h"
#include "config.h"
#include <libdragon.h>
#include <malloc.h>
#include <string.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// Global audio variables
static float cos_table[FFT_SIZE];
static float sin_table[FFT_SIZE];
static int fft_initialized = 0;

// WAV file header structure
typedef struct {
    char riff[4];           // "RIFF"
    uint32_t filesize;      // File size - 8
    char wave[4];           // "WAVE"
    char fmt[4];            // "fmt "
    uint32_t fmt_size;      // Format chunk size
    uint16_t format;        // Audio format (1 = PCM)
    uint16_t channels;      // Number of channels
    uint32_t sample_rate;   // Sample rate
    uint32_t byte_rate;     // Byte rate
    uint16_t block_align;   // Block align
    uint16_t bits_per_sample; // Bits per sample
    char data[4];           // "data"
    uint32_t data_size;     // Data size
} __attribute__((packed)) wav_header_t;

// Initialize audio system
int visualizer_audio_init(void) {
    // Initialize N64 audio system
    audio_init(44100, 4);
    
    #if DEBUG_ENABLED
    debugf("Audio system initialized\n");
    debugf("- Sample rate: %d Hz\n", SAMPLE_RATE);
    debugf("- Channels: %d\n", CHANNELS);
    debugf("- Buffer size: %d\n", BUFFER_SIZE);
    #endif
    
    return 0;
}

// Load WAV file (simplified for N64)
int audio_load_wav(const char *filename, audio_track_t *track) {
    // For N64, we'll embed the audio data directly
    // This is a simplified approach - in practice you'd read from filesystem
    
    #if DEBUG_ENABLED
    debugf("Loading audio: %s\n", filename);
    #endif
    
    // Initialize track structure
    track->samples = NULL;
    track->length = 0;
    track->position = 0;
    track->playing = 0;
    
    // In a real implementation, you would:
    // 1. Open the WAV file
    // 2. Parse the header
    // 3. Load the audio data
    // 4. Convert to the format needed
    
    // For this example, we'll create a placeholder
    // You would replace this with actual file loading
    
    #if DEBUG_ENABLED
    debugf("Audio loaded successfully\n");
    debugf("- Length: %d samples\n", track->length);
    #endif
    
    return 0;
}

// Play audio track
void audio_play(audio_track_t *track) {
    if (track && track->samples) {
        track->playing = 1;
        track->position = 0;
        
        #if DEBUG_ENABLED
        debugf("Playing audio track\n");
        #endif
    }
}

// Stop audio track
void audio_stop(audio_track_t *track) {
    if (track) {
        track->playing = 0;
        
        #if DEBUG_ENABLED
        debugf("Stopped audio track\n");
        #endif
    }
}

// Initialize FFT lookup tables
void fft_init(void) {
    if (fft_initialized) return;
    
    for (int i = 0; i < FFT_SIZE; i++) {
        float angle = -2.0f * M_PI * i / FFT_SIZE;
        cos_table[i] = cosf(angle);
        sin_table[i] = sinf(angle);
    }
    
    fft_initialized = 1;
    
    #if DEBUG_ENABLED
    debugf("FFT initialized\n");
    #endif
}

// Simple FFT implementation (Cooley-Tukey algorithm)
void fft_compute(int16_t *samples, float *output, int size) {
    if (!fft_initialized) fft_init();
    
    // Convert input samples to complex numbers
    static float real[FFT_SIZE];
    static float imag[FFT_SIZE];
    
    // Copy and normalize input
    for (int i = 0; i < size && i < FFT_SIZE; i++) {
        real[i] = (float)samples[i] / 32768.0f; // Normalize 16-bit samples
        imag[i] = 0.0f;
    }
    
    // Zero pad if necessary
    for (int i = size; i < FFT_SIZE; i++) {
        real[i] = 0.0f;
        imag[i] = 0.0f;
    }
    
    // Bit-reversal
    int j = 0;
    for (int i = 1; i < FFT_SIZE; i++) {
        int bit = FFT_SIZE >> 1;
        while (j & bit) {
            j ^= bit;
            bit >>= 1;
        }
        j ^= bit;
        
        if (i < j) {
            // Swap real[i] with real[j]
            float temp = real[i];
            real[i] = real[j];
            real[j] = temp;
            
            // Swap imag[i] with imag[j]
            temp = imag[i];
            imag[i] = imag[j];
            imag[j] = temp;
        }
    }
    
    // FFT computation
    for (int len = 2; len <= FFT_SIZE; len <<= 1) {
        int step = FFT_SIZE / len;
        for (int i = 0; i < FFT_SIZE; i += len) {
            for (int j = 0; j < len / 2; j++) {
                int u = i + j;
                int v = i + j + len / 2;
                int w = j * step;
                
                float wr = cos_table[w];
                float wi = sin_table[w];
                
                float vr = real[v] * wr - imag[v] * wi;
                float vi = real[v] * wi + imag[v] * wr;
                
                real[v] = real[u] - vr;
                imag[v] = imag[u] - vi;
                real[u] += vr;
                imag[u] += vi;
            }
        }
    }
    
    // Calculate magnitudes and store in output
    for (int i = 0; i < size / 2; i++) {
        output[i] = sqrtf(real[i] * real[i] + imag[i] * imag[i]);
    }
}

// Convert FFT output to frequency bins for visualization
void fft_to_frequency_bins(float *fft_output, float *frequency_bins, int fft_size, int num_bins) {
    int bin_size = (fft_size / 2) / num_bins;
    
    for (int i = 0; i < num_bins; i++) {
        float sum = 0.0f;
        int start = i * bin_size;
        int end = start + bin_size;
        
        // Average the FFT bins
        for (int j = start; j < end && j < fft_size / 2; j++) {
            sum += fft_output[j];
        }
        
        frequency_bins[i] = sum / bin_size;
        
        // Apply logarithmic scaling for better visualization
        frequency_bins[i] = logf(1.0f + frequency_bins[i] * 10.0f);
    }
}

// Update audio and get frequency data
void audio_update(audio_track_t *track, float *frequency_data) {
    if (!track || !track->playing || !track->samples) {
        // If no audio playing, generate demo pattern
        static uint32_t demo_time = 0;
        demo_time++;
        
        for (int i = 0; i < NUM_FREQUENCY_BINS; i++) {
            float freq = (float)i / NUM_FREQUENCY_BINS;
            float time = demo_time * 0.1f;
            
            // Create realistic audio spectrum simulation
            float bass = sinf(time * 0.5f + freq * 2.0f) * 0.4f + 0.4f;
            float mid = sinf(time * 0.8f + freq * 8.0f) * 0.3f + 0.3f;
            float treble = cosf(time * 1.2f + freq * 15.0f) * 0.2f + 0.2f;
            
            frequency_data[i] = bass + mid + treble;
        }
        return;
    }
    
    // Get current audio samples
    static int16_t current_samples[FFT_SIZE];
    static float fft_output[FFT_SIZE];
    
    // Copy samples from current position
    int samples_to_copy = FFT_SIZE;
    if (track->position + samples_to_copy > track->length) {
        samples_to_copy = track->length - track->position;
    }
    
    memcpy(current_samples, &track->samples[track->position], samples_to_copy * sizeof(int16_t));
    
    // Zero pad if necessary
    if (samples_to_copy < FFT_SIZE) {
        memset(&current_samples[samples_to_copy], 0, (FFT_SIZE - samples_to_copy) * sizeof(int16_t));
    }
    
    // Compute FFT
    fft_compute(current_samples, fft_output, FFT_SIZE);
    
    // Convert to frequency bins
    fft_to_frequency_bins(fft_output, frequency_data, FFT_SIZE, NUM_FREQUENCY_BINS);
    
    // Advance audio position
    track->position += BUFFER_SIZE;
    if (track->position >= track->length) {
        track->position = 0; // Loop
    }
}

// Cleanup audio resources
void audio_cleanup(audio_track_t *track) {
    if (track && track->samples) {
        free(track->samples);
        track->samples = NULL;
        track->length = 0;
        track->position = 0;
        track->playing = 0;
        
        #if DEBUG_ENABLED
        debugf("Audio track cleaned up\n");
        #endif
    }
} 