#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>


typedef struct node{
	int key;
	bool already_used;
	
	struct node* next;
}node;

#define HASHSIZE 100
static node* hashtable[HASHSIZE];//static =====> initial = NULL
 
unsigned int hash(int key) {
	unsigned int h ;
	
	h = (unsigned int)key;

	return h % HASHSIZE;
}

//=====================================================================
node* malloc_node(int key) {
	node* np = (node*)malloc(sizeof(node));

	np->key = key;
	np->already_used = false;
	np->next = NULL;
	
	return np;
}

void insert(int key) {
	unsigned int hashvalue = hash(key); //get hashvalue
	
	node* np = malloc_node(key);
	np->next = hashtable[hashvalue]; //initial hashtable[hashvalue] = NULL (because static)
	hashtable[hashvalue] = np; //update hashtable[hashvalue] to np(head of th link list)
}

//=====================================================================
bool search(int key, int key_i, int key_j) {
	unsigned int hashvalue;
	node* np;
	node* np_i;
	node* np_j;
	
	
	hashvalue = hash(key_i);
	for(np_i=hashtable[hashvalue]; np_i!=NULL; np_i=np_i->next) {
		if(np_i->key == key)
			break; //np must could be found!
	}
	
	hashvalue = hash(key_j);
	for(np_j=hashtable[hashvalue]; np_j!=NULL; np_j=np_j->next) {
		if(np_j->key == key)
			break; //np must could be found!
	}
	
	hashvalue = hash(key);
	for(np=hashtable[hashvalue]; np!=NULL; np=np->next) {
		if(np->key == key)
			break; //np maybe NULL
	}
	
	
	if(np == NULL  ||  np_i->already_used & np_j->already_used)
		return false;	
	else {
		np_i->already_used = true;
		np_j->already_used = true;
		np->already_used = true;
		return ture
	}
}

//=====================================================================
void clearHashTable() {
	node* np;
	node* temp;
	int i;
	
	for(i=0; i<HASHSIZE; i++) {
		np = hashtable[i];
		hashtable[i] = NULL; //turn hashtable[i] to NULL first!!!
		while(np != NULL) {
			temp = np //set current np to temp
			np = np->next; //set np to next np
			free(temp);	//free previous np
		}
	}
}



//######################################################################################################
int** threeSum(int* nums, int numsSize, int* returnSize, int** returnColumnSizes){
	int i, j;
	int key;
	int (*temp)[3];
	
	clearHashTable(); //clean HashTable first!
	
	for(i=0; i<numsSize; i++) {
		insert(nums[i], i);
	}
	
	*returnSize = 0;
	for(i=0; i<numsSize; i++) {
		for(j=i+1; j<numsSize; j++) {
			key = 0-nums[i]-nums[j];
			if(search(key, nums[i], nums[j]) == true) {
				temp[*returnSize][0] = key;
				temp[*returnSize][1] = nums[i];
				temp[*returnSize][2] = nums[j];
				*returnSize ++;
			}
		}
	}
	
	int** result = (int**)malloc(*returnSize*sizeof(int*));
	for(i=0; i<*returnSize; i++) {
		result[i] = (int*)malloc(3*sizeof(int));
		result[i][0] = temp[i][0];
		result[i][1] = temp[i][1];
		result[i][2] = temp[i][2];
	}
	
	returnColumnSizes[0] = (int*)malloc(*returnSize * sizeof(int)); 
	//returnColumnSizes[0] = *returnColumnSizes
	for(i=0; i<returnSize; i++) {
		returnColumnSizes[0][i] = 3;
	}
	
	
	return result;
}


int main() {
	int nums[6] = {-1, 0, 1, 2, -1, -4};
	int numsSize = 6;
	int* returnSize;
	int** returnColumnSizes;
	int** result;
	
	result = threeSum(nums, numsSize, returnSize, returnColumnSizes);
	
	for(int i=0; i<returnSize; i++) {
		printf("%d, ", int[i][0]);
		printf("%d, ", int[i][1]);
		printf("%d\n", int[i][2]);
	}
	
	return 0;
}
