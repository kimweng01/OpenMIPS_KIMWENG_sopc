#########################################################################

CONFIG_SHELL	:= $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
		    else if [ -x /bin/bash ]; then echo /bin/bash; \
		    else echo sh; fi ; fi)

HOSTCC		= cc
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
		###-Wstrict-prototypes為要求函數宣告必須要有參數類型，否則發出警告
		###-O2為做最佳化
		###-fomit-frame-pointer參考https://www.itread01.com/p/1373805.html

#########################################################################

#
# Include the make variables (CC, etc...)
#
AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)ranlib

CFLAGS += -I$(TOPDIR)/include -I$(TOPDIR)/ucos -I$(TOPDIR)/common \
		-Wall -Wstrict-prototypes -Werror-implicit-function-declaration -fomit-frame-pointer \
		-fno-strength-reduce -O2 -g -pipe -fno-builtin -nostdlib -mips32
		###-Wall表示顯示所有警告
		###-Wstrict-prototypes為沒有指定參數類型的聲明或定義的函數發出警告
		###-Werror-implicit-function-declaration為所有函數必須要有隱式聲明(即先宣告)，
		###否則報錯，不加此條則只報警
		###-fomit-frame-pointer參考https://www.itread01.com/p/1373805.html
		###-fno-strength-reduce把強度較高的操作(例如乘法)換成強度較低的操作(例如減法)
		###-O2為做最佳化
		###-g編入除錯資訊 (使用 GDB 除錯時用)
		###-pipe使用管道而不是臨時文件在編譯的各個階段之間進行通信，效益貌似不大
		###-fno-builtin為不採用內建函數
		###-nostdlib為不連接系統標準啟動文件和標準庫文件，只把指定的文件傳遞給連接器
		###-mips32表示編譯成MIPS32的組語
		
ASFLAGS += $(CFLAGS)

LDFLAGS += -lgcc -e 256

#########################################################################

export	CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE \
	AS LD CC AR NM STRIP OBJCOPY OBJDUMP \
	MAKE CFLAGS ASFLAGS
		###在（parent，上層的）makefile中export出來變數，讓子makefile（sub make）可以訪問。

#########################################################################

%.o:	%.S
	$(CC) $(CFLAGS) -c -o $@ $<
%.o:	%.c
	$(CC) $(CFLAGS) -c -o $@ $<

#########################################################################
