# ============================================================
#  Makefile — ATmega328P
# ============================================================

MCU       := atmega328p
F_CPU     := 16000000UL
PROGRAMMER := arduino
PORT      := /dev/ttyUSB0
BAUD      := 115200

CC      := avr-gcc
OBJCOPY := avr-objcopy
OBJDUMP := avr-objdump
SIZE    := avr-size
AVRDUDE := avrdude

CFLAGS  := -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall -Wextra -std=c99 \
            -ffunction-sections -fdata-sections
LDFLAGS := -mmcu=$(MCU) -Wl,--gc-sections

SRC     := main.c, i2c_init.c
ELF     := main.elf, i2c_init.elf
HEX     := main.hex, i2c_init.hex
MAP     := main.map, i2c_init.map
BIN		:= main.bin, i2c_init.bin

# ════════════════════════════════════════════════════════════

.PHONY: all clean flash size disasm

all: $(HEX) $(BIN) flash
	@echo "Build OK --> $(HEX) & $(BIN)"
	@$(SIZE) --mcu=$(MCU) --format=avr $(ELF)

$(ELF): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(ELF) $(SRC)

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex -R .eeprom $(ELF) $(HEX)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary -R .eeprom $(ELF) $(BIN)

flash: $(HEX)
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD) \
	           -U flash:w:$(HEX):i

size: $(ELF)
	$(SIZE) --mcu=$(MCU) --format=avr $(ELF)

disasm: $(ELF)
	$(OBJDUMP) -d -S $(ELF)

clean:
	rm -f $(ELF) $(HEX) $(MAP) $(BIN)
