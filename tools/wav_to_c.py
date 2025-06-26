#!/usr/bin/env python3
"""
WAV to C Array Converter
Converte arquivos WAV para arrays C que podem ser incluídos na ROM do N64
"""

import wave
import sys
import os

def wav_to_c_array(input_file, output_file, array_name="audio_data"):
    """
    Converte um arquivo WAV para um array C
    """
    try:
        # Abrir arquivo WAV
        with wave.open(input_file, 'rb') as wav_file:
            # Verificar parâmetros do áudio
            channels = wav_file.getnchannels()
            sample_width = wav_file.getsampwidth()
            sample_rate = wav_file.getframerate()
            num_frames = wav_file.getnframes()
            
            print(f"📊 Informações do áudio:")
            print(f"   - Canais: {channels}")
            print(f"   - Sample rate: {sample_rate} Hz")
            print(f"   - Sample width: {sample_width} bytes")
            print(f"   - Frames: {num_frames}")
            print(f"   - Duração: {num_frames / sample_rate:.2f} segundos")
            
            # Verificar se é compatível
            if channels != 1:
                print("⚠️  Convertendo para mono...")
            
            if sample_width != 2:
                print("⚠️  Apenas 16-bit suportado!")
                return False
                
            # Ler dados de áudio
            audio_data = wav_file.readframes(num_frames)
            
            # Converter para array de int16
            import struct
            samples = []
            
            if channels == 1:
                # Mono - direto
                for i in range(0, len(audio_data), 2):
                    sample = struct.unpack('<h', audio_data[i:i+2])[0]
                    samples.append(sample)
            else:
                # Estéreo - converter para mono (média)
                for i in range(0, len(audio_data), 4):
                    left = struct.unpack('<h', audio_data[i:i+2])[0]
                    right = struct.unpack('<h', audio_data[i+2:i+4])[0]
                    mono = (left + right) // 2
                    samples.append(mono)
            
            # Gerar arquivo C
            with open(output_file, 'w') as c_file:
                c_file.write(f"// Audio data converted from {input_file}\n")
                c_file.write(f"// Generated automatically - do not edit\n\n")
                c_file.write(f"#include <stdint.h>\n\n")
                c_file.write(f"// Audio parameters\n")
                c_file.write(f"#define AUDIO_SAMPLE_RATE {sample_rate}\n")
                c_file.write(f"#define AUDIO_CHANNELS {1}\n")  # Sempre mono
                c_file.write(f"#define AUDIO_LENGTH {len(samples)}\n")
                c_file.write(f"#define AUDIO_DURATION_MS {int(len(samples) * 1000 / sample_rate)}\n\n")
                
                # Array de dados
                c_file.write(f"const int16_t {array_name}[{len(samples)}] = {{\n")
                
                # Escrever samples em linhas de 16 valores
                for i in range(0, len(samples), 16):
                    line_samples = samples[i:i+16]
                    line_str = "    " + ", ".join(f"{s:6d}" for s in line_samples)
                    if i + 16 < len(samples):
                        line_str += ","
                    c_file.write(line_str + "\n")
                
                c_file.write("};\n")
                
                # Header correspondente
                header_file = output_file.replace('.c', '.h')
                with open(header_file, 'w') as h_file:
                    guard_name = os.path.basename(header_file).upper().replace('.', '_')
                    h_file.write(f"#ifndef {guard_name}\n")
                    h_file.write(f"#define {guard_name}\n\n")
                    h_file.write(f"#include <stdint.h>\n\n")
                    h_file.write(f"// Audio parameters\n")
                    h_file.write(f"#define AUDIO_SAMPLE_RATE {sample_rate}\n")
                    h_file.write(f"#define AUDIO_CHANNELS {1}\n")
                    h_file.write(f"#define AUDIO_LENGTH {len(samples)}\n")
                    h_file.write(f"#define AUDIO_DURATION_MS {int(len(samples) * 1000 / sample_rate)}\n\n")
                    h_file.write(f"extern const int16_t {array_name}[{len(samples)}];\n\n")
                    h_file.write(f"#endif // {guard_name}\n")
            
            print(f"✅ Conversão concluída!")
            print(f"   - Arquivo C: {output_file}")
            print(f"   - Header: {header_file}")
            print(f"   - Samples: {len(samples)}")
            print(f"   - Tamanho: {len(samples) * 2} bytes")
            
            return True
            
    except Exception as e:
        print(f"❌ Erro: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 wav_to_c.py <arquivo.wav> [nome_array]")
        print("Exemplo: python3 wav_to_c.py intensidade-intro.wav intensidade_audio")
        sys.exit(1)
    
    input_file = sys.argv[1]
    array_name = sys.argv[2] if len(sys.argv) > 2 else "audio_data"
    
    # Gerar nome do arquivo de saída
    base_name = os.path.splitext(os.path.basename(input_file))[0]
    output_file = f"src/{base_name}_data.c"
    
    print(f"🎵 Convertendo {input_file} para dados C...")
    
    if not os.path.exists(input_file):
        print(f"❌ Arquivo não encontrado: {input_file}")
        sys.exit(1)
    
    # Criar diretório src se não existir
    os.makedirs("src", exist_ok=True)
    
    success = wav_to_c_array(input_file, output_file, array_name)
    
    if success:
        print(f"\n📋 Próximos passos:")
        print(f"1. Inclua o header no main.c:")
        print(f"   #include \"{base_name}_data.h\"")
        print(f"2. Use os dados:")
        print(f"   track.samples = (int16_t*){array_name};")
        print(f"   track.length = AUDIO_LENGTH;")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main() 