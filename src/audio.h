#ifndef AUDIO_H
#define AUDIO_H

#include <stdint.h>

// Audio configuration
#define SAMPLE_RATE         44100
#define SAMPLE_BITS         16
#define CHANNELS            1       // Mono
#define BUFFER_SIZE         1024
#define FFT_SIZE            512
#define NUM_FREQUENCY_BINS  64

// Audio data structures
typedef struct {
    int16_t *samples;
    int length;
    int position;
    int playing;
} audio_track_t;

typedef struct {
    float magnitude;
    float phase;
} fft_bin_t;

// Function prototypes
int visualizer_audio_init(void);
int audio_load_wav(const char *filename, audio_track_t *track);
void audio_play(audio_track_t *track);
void audio_stop(audio_track_t *track);
void audio_update(audio_track_t *track, float *frequency_data);
void audio_cleanup(audio_track_t *track);

// FFT functions
void fft_init(void);
void fft_compute(int16_t *samples, float *output, int size);
void fft_to_frequency_bins(float *fft_output, float *frequency_bins, int fft_size, int num_bins);

#endif // AUDIO_H 