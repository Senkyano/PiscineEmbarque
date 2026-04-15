# ============================================================
#  CONFIG
# ============================================================
MCU        := atmega328p
F_CPU      := 16000000UL
PROGRAMMER := arduino
PORT       := /dev/ttyUSB0
BAUD       := 115200

FILES      := main
TARGET     := mon_programme

SRCS       := $(addsuffix .c, $(FILES))
OBJS       := $(addsuffix .o, $(FILES))

ELF        := $(TARGET).elf
HEX        := $(TARGET).hex
BIN        := $(TARGET).bin
MAP        := $(TARGET).map

# Outils
CC         := avr-gcc
OBJCOPY    := avr-objcopy
OBJDUMP    := avr-objdump
SIZE       := avr-size
AVRDUDE    := avrdude

CFLAGS     := -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall -Wextra -std=c99 \
              -ffunction-sections -fdata-sections
LDFLAGS    := -mmcu=$(MCU) -Wl,--gc-sections

# ============================================================
#  RULES
# ============================================================
.PHONY: all clean flash size disasm

all: $(HEX) $(BIN) flash
	@echo "Build OK --> $(HEX) & $(BIN)"
	@$(SIZE) --mcu=$(MCU) --format=avr $(ELF)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ELF): $(OBJS)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $@ $(OBJS)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary -R .eeprom $< $@

flash: $(HEX)
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD) \
	           -U flash:w:$(HEX):i

clean:
	rm -f *.o $(ELF) $(HEX) $(BIN) $(MAP)