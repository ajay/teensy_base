################################################################################

SHELL = bash

NUM_CPU = $(shell nproc --all)

MAKEFLAGS += -rR						# do not use make's built-in rules and variables
MAKEFLAGS += -j$(NUM_CPU)				# parallel processing
MAKEFLAGS += -k							# keep going
MAKEFLAGS += --warn-undefined-variables

ECHO = echo -e
RM   = rm -rf

ifeq ("$(origin verbose)", "command line")
	Q =
else
	Q = @
endif

################################################################################

PROJECT_NAME = $(notdir $(CURDIR))

$(info )
$(info PROJECT=$(PROJECT_NAME))
$(info )

SOURCE_DIR = src
OBJECT_DIR = obj
OUTPUT_DIR = out

SRC_FILE_EXTS = .asm .c .cpp

MCU = MK20DX256		# Teensy 3.1/3.2
# MCU = MKL26Z64	# Teensy LC
# MCU = MK64FX512	# Teensy 3.5
# MCU = MK66FX1M0	# Teensy 3.6

CPUARCH = cortex-m4			# Teensy 3.x
# CPUARCH = cortex-m0plus	# Teensy LC

################################################################################

ELF_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME).elf
MAP_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME).map
HEX_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME).hex
BIN_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME).bin
DIS_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME).dis

LINKER_FILE_PATH :=	$(sort $(shell find -L $(SOURCE_DIR) -type f -name '*.ld' -printf '%h\n'))

MCU    := $(strip $(MCU))
MCU_LD  = $(LINKER_FILE_PATH)/$(shell echo $(MCU) | tr A-Z a-z).ld

CPUARCH := $(strip $(CPUARCH))

################################################################################

CC       = arm-none-eabi-gcc
CXX      = arm-none-eabi-g++
OBJCOPY  = arm-none-eabi-objcopy
OBJDUMP  = arm-none-eabi-objdump
SIZE     = arm-none-eabi-size

DEFINES  = -DF_CPU=48000000
DEFINES += -DUSB_SERIAL
DEFINES += -DLAYOUT_US_ENGLISH
DEFINES += -DUSING_MAKEFILE
DEFINES += -D__$(MCU)__
DEFINES += -DARDUINO=10805
DEFINES += -DTEENSYDUINO=144

# common compiler options for C and C++
CPPFLAGS  = -Wall
CPPFLAGS += -Werror
CPPFLAGS += -g
CPPFLAGS += -Os
CPPFLAGS += -mcpu=$(CPUARCH)
CPPFLAGS += -mthumb
CPPFLAGS += -MMD				# generate dependency file
CPPFLAGS += -c					# compile and assemble, do not link
CPPFLAGS += $(DEFINES)
CPPFLAGS += $(INCLUDE_DIRS)

# compiler options for C only
CFLAGS  = -std=c11
CFLAGS += -x c

# compiler options for C++ only
CXXFLAGS  = -std=gnu++14
CXXFLAGS += -felide-constructors
CXXFLAGS += -fno-exceptions
CXXFLAGS += -fno-rtti
CXXFLAGS += -x c++

LDFLAGS  = -Os
LDFLAGS += -Wl,--gc-sections,--defsym=__rtc_localtime=0,-Map=$(MAP_FILE)
LDFLAGS += --specs=nano.specs
LDFLAGS += -mcpu=$(CPUARCH)
LDFLAGS += -mthumb
LDFLAGS += -T$(MCU_LD)

# additional libraries to link
LIBS = -lm

HEX_FLAGS  = -O ihex
HEX_FLAGS += -R .eeprom

BIN_FLAGS  = -O binary
BIN_FLAGS += -R .eeprom

DIS_FLAGS  = --all

################################################################################

UPLOADER = teensy_loader_cli

UPLOAD_FLAGS  = --mcu=$(MCU)
UPLOAD_FLAGS += -w				# wait for device
UPLOAD_FLAGS += -v				# verbose
UPLOAD_FLAGS += -s				# send soft reboot command

################################################################################

PICOCOM = picocom

dev  ?= /dev/ttyACMO
baud ?= 115200

PICOCOM_FLAGS  = --baud $(baud)
PICOCOM_FLAGS += --echo
PICOCOM_FLAGS += --omap crlf
PICOCOM_FLAGS += --emap crlf

################################################################################

INCLUDE_DIRS	:=	$(addprefix -I,						\
					$(sort $(shell find -L $(SOURCE_DIR) -type d)))

OBJS			:=	$(sort								\
					$(addprefix $(OBJECT_DIR)/,			\
					$(addsuffix .o,						\
					$(basename							\
					$(foreach ext, $(SRC_FILE_EXTS),	\
					$(shell test -d $(SOURCE_DIR) && find $(SOURCE_DIR) -type f -name *$(ext) -printf '%P\n'))))))

################################################################################

.PHONY: all help clean rebuild upload serial
.SECONDARY: $(OBJS)

all: $(ELF_FILE) $(HEX_FILE) $(BIN_FILE) $(DIS_FILE)

help:
	@$(ECHO)
	@$(ECHO) 'make                    - build project'
	@$(ECHO) '    verbose=<true>      - optional, default is false'
	@$(ECHO)
	@$(ECHO) 'make upload             - upload hex file to teensy board'
	@$(ECHO)
	@$(ECHO) 'make serial             - start picocom to communicate with teensy'
	@$(ECHO) '    dev=<device>        - optional, default is /dev/ttyACM0'
	@$(ECHO) '    baud=<baud>         - optional, default is 115200'
	@$(ECHO)
	@$(ECHO) 'make clean              - clean object & output files'
	@$(ECHO)
	@$(ECHO) 'make rebuild            - clean & make'
	@$(ECHO)
	@$(ECHO) 'make help               - this menu'
	@$(ECHO)



$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.asm
	@    $(ECHO) "(ASM)" $<
	@    mkdir -p $(@D)
	$(Q) $(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $<

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.c
	@    $(ECHO) "(CC) " $<
	@    mkdir -p $(@D)
	$(Q) $(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $<

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	@    $(ECHO) "(CXX)" $<
	@    mkdir -p $(@D)
	$(Q) $(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ $<

$(ELF_FILE): $(OBJS) $(MCU_LD)
	@    $(ECHO) "\n(LINK)" $@ "\n"
	@    mkdir -p $(@D)
	$(Q) $(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	$(Q) $(SIZE) $@
	@    $(ECHO)



%.hex: %.elf
	@    $(ECHO) "(HEX) " $@
	$(Q) $(OBJCOPY) $(HEX_FLAGS) $< $@

%.bin: %.elf
	@    $(ECHO) "(BIN) " $@
	$(Q) $(OBJCOPY) $(BIN_FLAGS) $< $@

%.dis: %.elf
	@    $(ECHO) "(DIS) " $@
	$(Q) $(OBJDUMP) $(DIS_FLAGS) $< > $@



upload: all
	$(Q) $(UPLOADER) $(UPLOAD_FLAGS) $(HEX_FILE)

serial:
	$(PICOCOM) /dev/ttyACM0 $(PICOCOM_FLAGS)



clean:
	$(RM) $(OUTPUT_DIR) $(OBJECT_DIR)
	@     $(ECHO) 'Finished clean\n'

rebuild: clean
	$(Q) $(MAKE) -s all



-include $(OBJS:.o=.d) # compiler generated dependency info
