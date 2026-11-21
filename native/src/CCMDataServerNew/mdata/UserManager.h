#ifndef BOYAA_USER_MANAGER_H
#define BOYAA_USER_MANAGER_H

#include <map>
#include <vector>
#include "GameUser.h"
using namespace std;
typedef map<int, CGameUser*> UserList;

class CUserManager
{
public:
	CUserManager(void);
	~CUserManager(void);

public:
	CGameUser* GetUser(int nUserId);
	int AddUser(int nUserId, CGameUser* pUser);
	int DelUser(int nUserId);
private:
	UserList m_UserList;
};

#endif
