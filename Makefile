BUILD_DIR = build
include $(N64_INST)/include/n64.mk

N64_ROM_TITLE = "Music Visualizer"
N64_ROM_SAVETYPE = none

SRCDIR = src
RESDIR = res

SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILD_DIR)/%.o)

MKSPRITE_FLAGS = 
MKFONT_FLAGS = 

# Compiler flags
N64_CFLAGS += -std=c99 -O2 -Wall -Werror -Wno-error=unused-variable -Wno-error=unused-function

$(BUILD_DIR)/visualizer.z64: N64_ROM_TITLE = "Music Visualizer"
$(BUILD_DIR)/visualizer.z64: $(OBJECTS)

$(BUILD_DIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(N64_CC) $(N64_CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: clean

# Additional targets for different build configurations
debug: N64_CFLAGS += -DDEBUG_ENABLED=1 -DSHOW_FPS=1 -O0 -g
debug: $(BUILD_DIR)/visualizer.z64

performance: N64_CFLAGS += -DNUM_BARS=32 -DGLOW_ENABLED=0 -O3
performance: $(BUILD_DIR)/visualizer.z64

full: N64_CFLAGS += -DNUM_BARS=64 -DGLOW_ENABLED=1 -DFLOW_LINES_ENABLED=1 -O2
full: $(BUILD_DIR)/visualizer.z64 