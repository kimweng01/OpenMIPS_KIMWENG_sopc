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

  	fp_bin = fopen("end poem.txt", "rb");
  	fp_hex = fopen("end_poem.txt", "w");
  	if (fp_bin == NULL)
    	printf("Can't read file!");

    else {
		stat("end poem.txt", &st);
		inst_num = (st.st_size+3) / 4; //向上取整
		printf("Total: %d instruction(s), %ld byte(s).\n\n", inst_num, st.st_size);

		for(i=0; i<inst_num; i++){
   			fread(buff, sizeof(char), 4, fp_bin);
			fprintf(fp_hex, "0x%02x,", buff[0]);
			fprintf(fp_hex, "0x%02x,", buff[1]);
			fprintf(fp_hex, "0x%02x,", buff[2]);
			fprintf(fp_hex, "0x%02x,", buff[3]);
		}
	}

	return 0;
}
