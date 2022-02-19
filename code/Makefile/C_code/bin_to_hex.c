#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>


int main(int argc, char *argv[]) {
	FILE *fp_bin, *fp_hex;
   	unsigned char buff[4];
	struct stat st;
	int inst_num;
	int i;
	
  	fp_bin = fopen("inst_rom.bin", "r");
  	fp_hex = fopen("inst_rom.txt", "w");
  	if (fp_bin == NULL)
    	printf("Can't read file!");
    	
    else {	
		stat("inst_rom.bin", &st);
		inst_num = st.st_size / 4;
		printf("Total: %d instruction(s), %ld byte(s).\n\n", inst_num, st.st_size);
	
		for(i=0; i<inst_num; i++){
   			fread(buff, sizeof(char), 4, fp_bin);
			//printf("%02x_", buff[0]);
			fprintf(fp_hex, "%02x_", buff[0]);
			//printf("%02x_", buff[1]);
			fprintf(fp_hex, "%02x_", buff[1]);
			//printf("%02x_", buff[2]);
			fprintf(fp_hex, "%02x_", buff[2]);
			//printf("%02x\n", buff[3]);
			fprintf(fp_hex, "%02x\n", buff[3]);
		}
	}
	
	return 0;
}
