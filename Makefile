PRERELEASE_VERSION ?= "01"

ifdef RELEASE_VERSION
	VERSION_DEFINE="-DRELEASE_VERSION=$(RELEASE_VERSION)"
else
	ifdef PRERELEASE_VERSION
		VERSION_DEFINE="-DPRERELEASE_VERSION=$(PRERELEASE_VERSION)"
	endif
endif

CC		   = cc65
AS		   = ca65
LD		   = ld65

# global includes
ASFLAGS	 += -I inc
ASFLAGS	 += $(VERSION_DEFINE)
ASFLAGS	 += -g
ASFLAGS	 += --cpu 65816
ASFLAGS	 += --relax-checks

BUILD_DIR=build/x16
EMU_DIR2=../x16-emulator
EMU_DIR1=/mnt/c/x16emu_win64-r49/drive
CFG_DIR=$(BUILD_DIR)/cfg

MAIN_ROOT = x16gs-test
OVERLAY1_ROOT = x16gs-test.ov1
OVERLAY2_ROOT = x16gs-test.ov2

# Define sources for the main program and overlays
MAIN_SOURCES = src/main.s src/malloc.s src/kernal.s src/file.s src/print.s src/linkedlist.s src/panel.s

# Define output binaries
MAIN_BIN = $(BUILD_DIR)/$(MAIN_ROOT).prg

# Define object files
MAIN_OBJS = $(addprefix $(BUILD_DIR)/, $(MAIN_SOURCES:.s=.o))

# Define configuration templates and generated configs
MAIN_CFG_TPL = cfg/$(MAIN_ROOT).cfgtpl

MAIN_CFG = $(CFG_DIR)/$(MAIN_ROOT).cfg

# Default target
all: $(MAIN_BIN)

# Install target
install: all	
	cp $(MAIN_BIN) $(EMU_DIR1)/$(MAIN_ROOT).prg
	cp $(BUILD_DIR)/$(OVERLAY1_ROOT).bin $(EMU_DIR1)/$(OVERLAY1_ROOT).bin
	cp $(BUILD_DIR)/$(OVERLAY2_ROOT).bin $(EMU_DIR1)/$(OVERLAY2_ROOT).bin

test: install
	@echo "Starting X16 Emulator..."
	x16emu -gs -scale 2 -quality linear -fsroot $(EMU_DIR1) -rtc -debug -prg $(MAIN_BIN) -run	

# Clean target
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(EMU_DIR1)/$(MAIN_BIN)
	rm -rf $(EMU_DIR1)/$(OVERLAY1_ROOT).bin
	rm -rf $(EMU_DIR1)/$(OVERLAY2_ROOT).bin

# Generate configuration files
$(CFG_DIR)/%.cfg: cfg/%.cfgtpl
	@mkdir -p $$(dirname $@)
	$(CC) -E $< -o $@
	cat $@ | sed "s!@BUILD_DIR@!$(BUILD_DIR)!" | sed "s!@OVERLAY1_ROOT@!$(OVERLAY1_ROOT)!" | sed "s!@OVERLAY2_ROOT@!$(OVERLAY2_ROOT)!" > $@.tmp
	mv $@.tmp $@	

# Compile assembly files
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@

# Link main program
$(MAIN_BIN): $(MAIN_OBJS) $(MAIN_CFG) 
	@mkdir -p $$(dirname $@)
	$(LD) -C $(MAIN_CFG) $(MAIN_OBJS) -o $@ -m $(BUILD_DIR)/$(MAIN_ROOT).map -Ln $(BUILD_DIR)/$(MAIN_ROOT).sym 