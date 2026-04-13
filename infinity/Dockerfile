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
 
WORKDIR /project
 
CMD [ "sleep", "infinity"] 