
# ============================================================
#  AVR Cross-Compilation Environment — ATmega328P
#  Compatible: x86_64, arm64 (Apple Silicon, Raspberry Pi…)
# ============================================================
FROM debian:bookworm-slim
 
LABEL maintainer="rihoy"
LABEL description="Cross-compilation environment for ATmega328P (avr-gcc + avrdude)"
 
# ── System packages ──────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc-avr            \
        binutils-avr       \
        avr-libc           \
        avrdude            \
        make               \
        gdb-avr            \
        simavr             \
        git                \
        ca-certificates    \
    && rm -rf /var/lib/apt/lists/*
 
# ── Working directory (mapped to host via volume) ────────────
WORKDIR /project
 
# ── Default command: drop into bash so you can run make ──────
# To compile with 
CMD ["bash"] 

# To enter in the docker
# CMD [ "sleep", "infinity"] 