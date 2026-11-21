#ifndef __GAME_TABLE_LIST_H__
#define __GAME_TABLE_LIST_H__

#include <noncopyable.h>
#include <GameTable.h>
#include <GameServer.h>

#include <string>
using std::string;

#define A2M_CREATE_TABLE_REDIS 0x3200
#define A2M_UPDATE_TABLE_STATUS 0x3201

class CTableList :
	private noncopyable
{
public:
	CTableList();
	~CTableList();

	static CTableList* Instance(void);
	//count桌子总数
	bool	init(CGameServer* pGameServer, CLogicServer* pServer, int count,int game_type);
	//更新桌子状态
	bool	updateStatus(CGameServer* pGameServer, CLogicServer* pServer, int tid, int uid, int status);
	//是否使用桌子列表功能
	bool	isUserTableList(){ return m_bUserTableList; };
	void	setUserTableList(bool val){ m_bUserTableList = val; };

private:

	bool	addTable(CLogicServer* pServer,int tid);

	int		GetMemDataRet(CMemDataServer* pMemServer, NETInputPacket& resPacket);

	bool	m_bUserTableList;
};



#endif