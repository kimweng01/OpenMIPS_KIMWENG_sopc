ifndef cross_compile
cross_compile = mips-sde-elf-
endif

CC = $(cross_compile)as
LD = $(cross_compile)ld
OBJCOPY = $(cross_compile)objcopy
OBJDUMP = $(cross_compile)objdump

OBJECTS = inst_rom.o

## compile rules

all: inst_rom.txt

%.o: %.s
	$(CC) -mips32 $< -o $@

inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@

inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $< $@

inst_rom.txt: inst_rom.bin
	./bin_to_hex

clean:
	rm -f *.o *.om *.bin
	# rm -f *.o *.om