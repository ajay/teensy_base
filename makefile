################################################################################

MAKEFLAGS += -rR						# do not use make's built-in rules and variables
MAKEFLAGS += -j8						# parallel processing
# MAKEFLAGS += --output-sync=target		# group output messages per target
MAKEFLAGS += --warn-undefined-variables

SHELL = bash
ECHO  = echo -e
RM    = rm -rf

ifeq ("$(origin verbose)", "command line")
	Q =
else
	Q = @
endif

################################################################################

PROJECT_NAME = test
# PROJECT_NAME = $(notdir $(CURDIR))

$(info )
$(info PROJECT=$(PROJECT_NAME))
$(info )

SOURCE_DIRS = lib src
OBJECT_DIR  = obj
OUTPUT_DIR  = out

LINKER_FILE_PATH = lib/linker

SRC_FILE_EXT_C   = .c
SRC_FILE_EXT_CPP = .cpp
HDR_FILE_EXT     = .h
OBJ_FILE_EXT     = .o
DEP_FILE_EXT     = .d
ELF_FILE_EXT     = .elf
MAP_FILE_EXT     = .map
HEX_FILE_EXT     = .hex
BIN_FILE_EXT     = .bin
DIS_FILE_EXT     = .dis
LINK_FILE_EXT    = .ld

ELF_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME)$(ELF_FILE_EXT)
MAP_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME)$(MAP_FILE_EXT)
HEX_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME)$(HEX_FILE_EXT)
BIN_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME)$(BIN_FILE_EXT)
DIS_FILE = $(OUTPUT_DIR)/$(PROJECT_NAME)$(DIS_FILE_EXT)

MCU = MK20DX256		# Teensy 3.1/3.2
# MCU = MKL26Z64	# Teensy LC
# MCU = MK64FX512	# Teensy 3.5
# MCU = MK66FX1M0 	# Teensy 3.6

MCU    := $(strip $(MCU))
MCU_LD  = $(LINKER_FILE_PATH)/$(shell echo $(MCU) | tr A-Z a-z)$(LINK_FILE_EXT)

CPUARCH  = cortex-m4		# Teensy 3.x
# CPUARCH = cortex-m0plus	# Teensy LC
CPUARCH := $(strip $(CPUARCH))

################################################################################

CC       = arm-none-eabi-gcc
CXX      = arm-none-eabi-g++
OBJCOPY  = arm-none-eabi-objcopy
OBJDUMP  = arm-none-eabi-objdump
SIZE     = arm-none-eabi-size
UPLOADER = teensy_loader_cli

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

UPLOAD_FLAGS  = --mcu=$(MCU)
UPLOAD_FLAGS += -w
UPLOAD_FLAGS += -v

################################################################################

C_SRCS			:=	$(foreach dir, $(SOURCE_DIRS),		\
					$(foreach ext, $(SRC_FILE_EXT_C), 	\
					$(shell test -d $(dir) && find $(dir) -type f -name *$(ext))))

CXX_SRCS		:=	$(foreach dir, $(SOURCE_DIRS),		\
					$(foreach ext, $(SRC_FILE_EXT_CPP), \
					$(shell test -d $(dir) && find $(dir) -type f -name *$(ext))))

DIRS 			:=	$(foreach dir, $(SOURCE_DIRS),		\
					$(sort $(shell find -L $(dir) -type d)))

INCLUDE_DIRS	:=	$(addprefix -I, $(DIRS))

OBJS 			:=	$(addprefix $(OBJECT_DIR)/, 		\
					$(C_SRCS:.c=.o) $(CXX_SRCS:.cpp=.o))

vpath %$(SRC_FILE_EXT_C)   $(DIRS)
vpath %$(SRC_FILE_EXT_CPP) $(DIRS)
vpath %$(HDR_FILE_EXT)     $(DIRS)

################################################################################

.PHONY: all help clean rebuild upload
.SECONDARY: $(OBJS)

all: $(ELF_FILE) $(HEX_FILE) $(BIN_FILE) $(DIS_FILE)

help:
	@$(ECHO)
	@$(ECHO) 'make                    - build project'
	@$(ECHO) '    verbose=<true>      - optional, default is false'
	@$(ECHO)
	@$(ECHO) 'make clean              - clean obj & output files'
	@$(ECHO)
	@$(ECHO) 'make rebuild            - clean & make'
	@$(ECHO)
	@$(ECHO) 'make upload             - upload hex file to teensy board'
	@$(ECHO)
	@$(ECHO) 'make help               - this menu'
	@$(ECHO)

$(OBJECT_DIR)/%$(OBJ_FILE_EXT): %$(SRC_FILE_EXT_C)
	@    $(ECHO) "(CC) " $@
	@    mkdir -p $(dir $@)
	$(Q) $(CC) $(INCLUDE_DIRS) $(CPPFLAGS) $(CFLAGS) -o $@ $<

$(OBJECT_DIR)/%$(OBJ_FILE_EXT): %$(SRC_FILE_EXT_CPP)
	@    $(ECHO) "(CXX)" $@
	@    mkdir -p $(dir $@)
	$(Q) $(CXX) $(INCLUDE_DIRS) $(CPPFLAGS) $(CXXFLAGS) -o $@ $<

$(ELF_FILE): $(OBJS) $(MCU_LD)
	@    $(ECHO) "\n(LINK)" $@ "\n"
	@    mkdir -p $(dir $@)
	$(Q) $(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	$(Q) $(SIZE) $@

%$(HEX_FILE_EXT): %$(ELF_FILE_EXT)
	@    $(ECHO) "\n(HEX) " $@
	@    mkdir -p $(dir $@)
	$(Q) $(OBJCOPY) $(HEX_FLAGS) $< $@

%$(BIN_FILE_EXT): %$(ELF_FILE_EXT) %$(HEX_FILE_EXT)
	@    $(ECHO) "\n(BIN) " $@
	@    mkdir -p $(dir $@)
	$(Q) $(OBJCOPY) $(BIN_FLAGS) $< $@

%$(DIS_FILE_EXT): %$(ELF_FILE_EXT) %$(BIN_FILE_EXT)
	@    $(ECHO) "\n(DIS) " $@ "\n"
	@    mkdir -p $(dir $@)
	$(Q) $(OBJDUMP) $(DIS_FLAGS) $< > $@

clean:
	$(RM) $(OBJECT_DIR)
	$(RM) $(OUTPUT_DIR)

rebuild: clean
	@$(MAKE) -s all

upload: $(HEX_FILE)
	$(UPLOADER) $(UPLOAD_FLAGS) $<

-include $(OBJS:.o=.d) # compiler generated dependency info
