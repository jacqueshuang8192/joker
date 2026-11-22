#include "DictTreeDW.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static DictTreeDW* instance = NULL;
static char dtretbuff[1024];
const char *dtpfill = "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ";
static char word[512] = {0};
int createTree(const char* file);
int filter(const char *content);


Node *rootNode = NULL;

DictTreeDW::DictTreeDW()
{
}

DictTreeDW* DictTreeDW::Instance()
{
	if(instance==NULL)
	{
		instance = new DictTreeDW();
	}
	return instance;
}

int DictTreeDW::Init(const char* file)
{
	if(rootNode != NULL)
		ClearResouce(rootNode);
	return createTree(file);
}

int DictTreeDW::FilterMsg(const char* msg)
{
	return filter(msg);
}

void DictTreeDW::ClearResouce(Node *p)
{
	if(p != NULL)
	{
		for(int i = 0; i < 256; i++)
		{
			if(p->next[i] != NULL)
			{
				ClearResouce(p->next[i]);
			}
		}
		delete p;
		p = NULL;
	}
}

#if 0
int filter(const char *content) { 
	memset(dtretbuff, 0, sizeof(dtretbuff));
	strcpy(dtretbuff, content);
	int conlen = 0;
	Node *node = rootNode;
	int wordindex = 0; //用于添加脏字符的索引
	int nstart,nend;   //用于替换字符的开始和结束
	nstart = nend = -1;
	int content_len = strlen(content);
	while(conlen < content_len) {   
		node = node->next[(unsigned char)content[conlen]];   
		if(node == NULL) {   
			node = rootNode;   
			conlen = conlen - strlen(word);   
			memset(word, 0, sizeof(word));
			wordindex = 0;
			nstart = nend = -1;
		} else if(node->bend == true) {   
			return 1;  //�ҵ�һ���ͷ���
		/*
			word[wordindex] = content[conlen];
			nend = conlen + 1;
			memcpy(dtretbuff + nstart, dtpfill, nend - nstart);
			wordindex = 0;
			nstart = nend = -1;
			node = rootNode;   
			*/
		} else {
			if(nstart == -1)
				nstart = conlen;
			word[wordindex] = content[conlen];
			wordindex++;
		}   
		conlen++;   
	}
/*
	size_t ret_len = strlen(dtretbuff);
	size_t minLen = content_len > ret_len ? ret_len : content_len;
	memcpy(content, dtretbuff, minLen);
*/	
	return 0;
}
#endif

int filter(const char * content) {
	int conlen = 0;
	int content_len = strlen(content);
	int matched = 0;
	Node * node = rootNode;
	
	while(conlen < content_len)
	{
		node = node->next[(unsigned char)content[conlen]];
		if(node == NULL)
		{
			node = rootNode;
			conlen -= matched;
			matched = 0;
		}
		else if(node->bend == true)
		{
			return 1;
		}
		else
		{
			++ matched;
		}

		++ conlen;
	}

	return 0;
}

void insertNode(Node* node, const char* cs, size_t index) {   
	Node* n = node->next[(unsigned char)cs[index]]; 
	if(n == NULL) {   
		n = new Node;  
		n->c = (unsigned char) cs[index];
		node->next[n->c] = n;   
	}   

	if(index == (strlen(cs)-1))   
		n->bend = true;   

	index++;   
	if(index<strlen(cs))   
		insertNode(n, cs, index);   
} 

#if 0
int createTree(const char* file) {

	rootNode = new Node;

	FILE * f = fopen(file,"r");
	if(f==NULL)
		return -1;
	char word[1024]={'\0'};
    while(fgets(word, 1024, f))
    {
		if(strlen(word) == 1)
			continue;
        word[strlen(word)-1] = '\0';
		size_t len = strlen(word);
		if(len > 0)
			insertNode(rootNode, word, 0);
    }
	fclose(f);
	return 0;
} 
#endif

int createTree(const char * file) {
	rootNode = new Node;
	FILE * f = fopen(file, "r");
	if(f == NULL)
		return -1;

	char line[1024] = {0};
	while(fgets(line, 1024, f))
	{
		int len = strlen(line);
		if(len <= 1)
			continue;

		line[--len] = 0;	//ȥ�����з�
		if(len > 0)
			insertNode(rootNode, line, 0);
	}

	fclose(f);

	return 0;
}

#ifdef DICT_TREE_MAIN
int main(int argc, char** argv)
{
	char lbuf[512];
	createTree(argv[1]);
	//searchWord();
	int lno = 0;
	int z;
	/* 逐行处理输入的数据 */
	while(fgets(lbuf, sizeof(lbuf), stdin))
	{
		++lno;
		if ((z = strlen(lbuf)) > 0 && lbuf[z-1] == '\n')
    		lbuf[z - 1] = 0;

		printf("%s\n", searchWord(lbuf));
		//printf("lbuf %s\n", lbuf);
	}
	return 0;
}
#endif
