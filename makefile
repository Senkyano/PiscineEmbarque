# ============================================================
#  Makefile racine — ATmega328P
#  Lance la compilation dans Docker pour chaque projet (exo*)
# ============================================================

IMAGE     := avr-env
MCU       := atmega328p
F_CPU     := 16000000UL
PROGRAMMER:= arduino
PORT      := /dev/ttyUSB0
BAUD      := 115200

# Détecte tous les dossiers exo* contenant un main.c
PROJECTS  := $(patsubst %/main.c,%,$(wildcard exo*/main.c))

# ════════════════════════════════════════════════════════════

.PHONY: all clean help build-image $(PROJECTS)

## Compile tous les projets
all: build-image $(PROJECTS)

## Build l'image Docker si elle n'existe pas
build-image:
	@docker image inspect $(IMAGE) > /dev/null 2>&1 || \
		(echo "[Docker] Build de l image $(IMAGE)..." && docker build -t $(IMAGE) .)

## Compile un projet spécifique : make exo0
$(PROJECTS):
	@echo ""
	@echo "==> Compilation de $@"
	@mkdir -p build/$@
	docker run --rm \
		-v $(CURDIR):/project \
		$(IMAGE) \
		avr-gcc \
			-mmcu=$(MCU) \
			-DF_CPU=$(F_CPU) \
			-Os -Wall -Wextra -std=c99 \
			-ffunction-sections -fdata-sections \
			-o /project/build/$@/main.elf \
			/project/$@/main.c \
			-Wl,--gc-sections -Wl,-Map=/project/build/$@/main.map
	docker run --rm \
		-v $(CURDIR):/project \
		$(IMAGE) \
		avr-objcopy -O ihex -R .eeprom \
			/project/build/$@/main.elf \
			/project/build/$@/main.hex
	@echo "[OK] build/$@/main.hex genere"

## Flash un projet : make flash exo0
flash:
	@test -n "$(filter-out $@,$(MAKECMDGOALS))" || \
		(echo "Usage: make flash exo0" && exit 1)

exo%: ;   # absorbe les arguments trailing (ex: make flash exo0)

flash-%:
	@echo "==> Flash de $*"
	docker run --rm \
		-v $(CURDIR):/project \
		--device $(PORT) \
		$(IMAGE) \
		avrdude -c $(PROGRAMMER) -p $(MCU) -P $(PORT) -b $(BAUD) \
		        -U flash:w:/project/build/$*/main.hex:i

## Affiche la taille d'un projet : make size-exo0
size-%:
	@docker run --rm \
		-v $(CURDIR):/project \
		$(IMAGE) \
		avr-size --mcu=$(MCU) --format=avr /project/build/$*/main.elf

## Supprime les binaires d'un projet : make clean-exo0
clean-%:
	rm -rf build/$*
	@echo "[OK] build/$* supprime"

## Supprime tout
clean:
	rm -rf build/
	@echo "[OK] Dossier build/ supprime"

## Rebuild l'image Docker
rebuild-image:
	docker build --no-cache -t $(IMAGE) .

help:
	@echo ""
	@echo "  make                  -> compile tous les projets (exo*)"
	@echo "  make exo0             -> compile exo0 uniquement"
	@echo "  make flash-exo0       -> flashe exo0"
	@echo "  make size-exo0        -> affiche Flash/RAM de exo0"
	@echo "  make clean-exo0       -> supprime build/exo0"
	@echo "  make clean            -> supprime tout build/"
	@echo "  make rebuild-image    -> rebuild l image Docker"
	@echo ""
	@echo "  Projets detectes : $(PROJECTS)"
	@echo ""