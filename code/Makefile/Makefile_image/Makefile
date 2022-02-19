ifndef cross_compile
cross_compile = mips-sde-elf-
endif

CC = $(cross_compile)as
LD = $(cross_compile)ld
OBJCOPY = $(cross_compile)objcopy
OBJDUMP = $(cross_compile)objdump

OBJECTS_BL = BootLoader.o
OBJECTS_OS = SimpleOS.o



##########################################################################
all: Image.bin


#===================BootLoader===================
BootLoader.o: BootLoader.s
	$(CC) -mips32 $< -o $@

BootLoader.om: BootLoader.ld $(OBJECTS_BL)
	$(LD) -T BootLoader.ld $(OBJECTS_BL) -o $@

BootLoader.bin: BootLoader.om
	$(OBJCOPY) -O binary $< $@


#===================SimpleOS===================
SimpleOS.o: SimpleOS.s
	$(CC) -mips32 $< -o $@

SimpleOS.om: SimpleOS.ld $(OBJECTS_OS)
	$(LD) -T SimpleOS.ld $(OBJECTS_OS) -o $@

SimpleOS.bin: SimpleOS.om
	$(OBJCOPY) -O binary $< $@
	


##########################################################################
#===================Image===================
Image.bin: BootLoader.bin SimpleOS.bin
	./Image



##########################################################################
#===================Clean===================	
clean:
	rm -f *.o *.om *.bin