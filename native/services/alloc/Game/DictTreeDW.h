#ifndef _DictTreeDW_H_
#define _DictTreeDW_H_
#include <string.h>
typedef struct Node
{
	unsigned char c;
	bool bend;
	struct Node *next[256];
	Node()
	{
		bend = false;
		memset(next, 0, sizeof(Node*)*256);
	}
}Node;

class DictTreeDW
{
	
	public:
		static DictTreeDW* Instance();
		virtual ~DictTreeDW(){};

	public:
		int FilterMsg(const char* msg);
		int Init(const char *file);

	private:
		DictTreeDW();
		void ClearResouce(Node *node);
		 
};
#endif
