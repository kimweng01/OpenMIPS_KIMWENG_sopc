#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>


int main(int argc, char *argv[]) {
	FILE *fp_bootloader, *fp_ucosii, *fp_image;
   	unsigned char buff;
	struct stat st_bootloader;
	struct stat st_ucosii;
	int i;

  	fp_bootloader = fopen("BootLoader.bin", "rb"); //if use "r", will stuck at \n
  	fp_ucosii = fopen("ucosii.bin", "rb"); //if use "r", will stuck at \n
  	fp_image = fopen("OS.bin", "wb");
  	if (fp_bootloader == NULL) {
    	printf("Can't read BootLoader.bin!");
    	return -1;
    }

    if (fp_ucosii == NULL) {
    	printf("Can't read ucosii.bin!");
    	return -1;
    }


    //=========================================================
    stat("BootLoader.bin", &st_bootloader);
    stat("ucosii.bin", &st_ucosii);
    //printf("st_bootloader.st_size = 0x%x\n", st_bootloader.st_size);

    for(i=0; i<st_bootloader.st_size; i++){
        fread(&buff, sizeof(char), 1, fp_bootloader);
        fwrite(&buff, 1, sizeof(char), fp_image);
    }

    //---------------------------------------------
    for(i=st_bootloader.st_size; i<768; i++) { //768 = 0x300
        buff = 0xff; //以ff填充空格
        fwrite(&buff, 1, sizeof(char), fp_image);
    }

    //---------------------------------------------
    //printf("st_ucosii.st_size = 0x%x\n", st_ucosii.st_size);
    //填寫大小
    buff = st_ucosii.st_size / 0x1000000;
    fwrite(&buff, 1, sizeof(char), fp_image);
    //printf("buff = %02x\n", buff);
    buff = st_ucosii.st_size / 0x10000 % 0x100;
    fwrite(&buff, 1, sizeof(char), fp_image);
    //printf("buff = %02x\n", buff);
    buff = st_ucosii.st_size / 0x100 % 0x100;
    fwrite(&buff, 1, sizeof(char), fp_image);
    //printf("buff = %02x\n", buff);
    buff = st_ucosii.st_size % 0x100;
    fwrite(&buff, 1, sizeof(char), fp_image);
    //printf("buff = %02x\n", buff);

    //---------------------------------------------
    for(i=768; i<768+st_ucosii.st_size; i++) {
        fread(&buff, sizeof(char), 1, fp_ucosii);
        fwrite(&buff, 1, sizeof(char), fp_image);
    }

	return 0;
}
