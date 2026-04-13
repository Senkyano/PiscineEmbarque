# AVR Cross-Compilation — ATmega328P

Environnement Docker portable pour compiler et flasher un ATmega328P
(Arduino Uno, Nano, Pro Mini…) depuis n'importe quelle machine.

```
ATmega328p/
├── Dockerfile
├── Makefile
├── podman-compose.yml
├── README.md
├── infinity/
|   └── Dockerfile 
└── src/
    └── main.c          ← ton code ici
```
---
## MANUAL MODE

## 1. build in the docker

Tu peux build ton projet directement dans le docker avec le docker compose qui simule tout l'environnement
```bash
# Copy ton projet dans le docker /project
docker/podman cp ./ton-dossier-projet avrinfinity:/project

# Ensuite tu pourras mv tes binaires dans le dossier associer aux project
mv main.elf main.hex main.map ../build
```


## AUTO MODE

## 1. Build de l'image Docker

```bash
docker build -t avr-env .
```

> À faire **une seule fois** (ou après modification du Dockerfile).

---

## 2. Compilation

Compilation avec le setup.sh

```bash
bash setup.sh compile nom_directory
```

### Autres commandes make

```bash
# Afficher Flash / RAM utilisés
docker run --rm -v $(pwd):/project avr-env make size

# Désassembler l'ELF
docker run --rm -v $(pwd):/project avr-env make disasm

# Nettoyer
docker run --rm -v $(pwd):/project avr-env make clean
```

---

## 3. Flash (avrdude)

Le flash nécessite l'accès au port USB/série de la machine hôte.

### Linux

```bash
# Installe avrdude sur Fedora
sudo dnf install avrdude -y

# Flash
avrdude -c arduino -p atmega328p \
        -P /dev/ttyUSB0 -b 115200 \
        -U flash:w:build/exo0/main.hex:i
```

> Remplace `/dev/ttyUSB0` par le bon port (`ls /dev/ttyUSB*` ou `ls /dev/ttyACM*`).

---

## 4. Adapter le Makefile

| Variable     | Valeur par défaut | Description                         |
|--------------|-------------------|-------------------------------------|
| `MCU`        | `atmega328p`      | Cible avr-gcc                       |
| `F_CPU`      | `16000000UL`      | Fréquence CPU (16 MHz)              |
| `PROGRAMMER` | `arduino`         | Type de programmateur avrdude       |
| `PORT`       | `/dev/ttyUSB0`    | Port série                          |
| `BAUD`       | `115200`          | Vitesse du bootloader               |

Override depuis la ligne de commande :

```bash
docker run --rm -v $(pwd):/project avr-env \
  make F_CPU=8000000UL PORT=/dev/ttyACM0
```

---

## Rappel registres ATmega328P

| Registre | Rôle                          |
|----------|-------------------------------|
| `DDRx`   | Direction (1 = sortie)        |
| `PORTx`  | Écriture / pull-up            |
| `PINx`   | Lecture de l'état physique    |

Ports disponibles : **B** (PB0–PB7), **C** (PC0–PC6), **D** (PD0–PD7).
