#include "UserManager.h"

CUserManager::CUserManager(void)
{
}

CUserManager::~CUserManager(void)
{
}

CGameUser* CUserManager::GetUser(int nUserId)
{
	CGameUser *pUser = NULL;
	UserList::iterator iter = m_UserList.find(nUserId);
	if (iter != m_UserList.end())
	{
		pUser = iter->second;
	}
	return pUser;
}

int CUserManager::AddUser(int nUserId, CGameUser* pUser)
{
	CGameUser* pOldUser = GetUser(nUserId);
	if (pOldUser == NULL)
	{
		m_UserList[nUserId] = pUser;
	}
	else
	{
		//ACE_DEBUG((LM_INFO, ACE_TEXT("AddUser||User exist")));
		return -1;
	}
	return 0;
}

int CUserManager::DelUser(int nUserId)
{
	UserList::iterator iter = m_UserList.find(nUserId);
	if(iter != m_UserList.end())
	{
		m_UserList.erase(iter);
	}
	return 0;
}


