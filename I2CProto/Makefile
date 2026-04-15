# ============================================================
#  CONFIG
# ============================================================
NAME            := i2c_protocole
NAME_LIBRARY    := lib$(NAME).a

FILES           := i2c_init
SRCS            := $(addsuffix .c, $(FILES))
OBJS            := $(SRCS:.c=.o)

# Outils
CC              := avr-gcc
AR              := avr-ar
RANLIB          := avr-ranlib

MCU             := atmega328p
CFLAGS          := -mmcu=$(MCU) -Os -Wall -Wextra -std=c99

# ============================================================
#  RULES
# ============================================================
all: $(NAME_LIBRARY)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME_LIBRARY): $(OBJS)
	$(AR) rcs $@ $^
	$(RANLIB) $@
	@echo "Library $@ created successfully!"

clean:
	rm -f $(OBJS) $(NAME_LIBRARY)
