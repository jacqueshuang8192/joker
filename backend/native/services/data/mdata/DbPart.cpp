#include "DbPart.h"
#include "time.h"
#include "global.h"

int CDbPart::m_tableNum = 0;
int CDbPart::m_dbNum = 0;
CDbPart::CDbPart()
{
	m_pMysqlConn = NULL;
	m_pStore = NULL;
}

CDbPart::~CDbPart()
{
	if (m_pMysqlConn)
	{
		delete m_pMysqlConn;
		m_pMysqlConn = NULL;
	}
}

int CDbPart::GetDatabaseIndex(int mid)
{
	return (mid/CDbPart::m_tableNum)%CDbPart::m_dbNum;
}

int CDbPart::GetTableIndex(int mid)
{
	return mid%m_tableNum;
}

BOOL CDbPart::ConnectDB(DatabaseParam& dbParam)
{
	try
	{
		m_pMysqlConn = new CMysqlConnect();
		if(!m_pMysqlConn->Connect(dbParam.host, dbParam.user, dbParam.password, dbParam.db, dbParam.port, dbParam.unix_socket, "utf8"))
		{
			ErrMsg("ConnectDB! ERROR:%s", m_pMysqlConn->What().c_str());
			return FALSE;
		}
		m_pStore = new CMysqlStore();
		m_pStore->SetTransAction(m_pMysqlConn);
		LogMsg("ConnectDB IP:%s,Port:%d",dbParam.host.c_str(),dbParam.port);
		return TRUE;
	}
	catch (...)
	{
		ErrMsg("ConnectDB exception:%s", m_pMysqlConn->What().c_str());
		return FALSE;
	}

	return FALSE;
}

BOOL CDbPart::CallProcedure(const char * strMysql)
{
	if(strMysql == "")
		return TRUE;
	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		return FALSE;
	}
	if(m_pStore->Exec(strMysql))
	{
		return TRUE;
	}
	m_strError = "ExecErr";
	m_strError += m_pStore->What();
	VLogMsg(CLIB_LOG_LEV_ERROR,"CallProcedure error:[%s]", m_strError.c_str());
	return FALSE;
}

int CDbPart::UpdateData(int uid,const UserInfo & data)
{
	char szSql[1000] = {0};
	snprintf(szSql, sizeof(szSql), "update bullfight_gameinfo%d set exp=%d, score=%d, money=%ld,wintimes=%d, losetimes=%d chip=%d where mid=%d", GetTableIndex(uid), data.exp, data.score, data.money, data.win, data.lose,data.chips, uid);
	CallProcedure(szSql);
	return 0;
}

int CDbPart::GetUserInfo(int nUserId, long int& nMoney,int& nExp,int& nScore,  int& nWinTimes, int& nLoseTimes,int& chips)
{
	char buf[512] = {0};
	std::string s_sql = "";
	snprintf(buf, 511,"select exp, score, money, wintimes, losetimes, chip from bullfight_gameinfo%d where mid=%d",GetTableIndex(nUserId),nUserId);
	s_sql = buf;

	if (m_pMysqlConn->GetConnect() == NULL)
	{
		m_strError = m_pMysqlConn->What();
		return -1;
	}
	if(m_pStore->Query(s_sql))
	
	{
		unsigned long count = m_pStore->RowCount();
		if(count <= 0)
		{
			return -1;
		}
		nMoney = m_pStore->GetItemLong(0, "money");
		nExp = m_pStore->GetItemLong(0, "exp");
		nScore = m_pStore->GetItemLong(0,"score");
		nWinTimes = m_pStore->GetItemLong(0, "wintimes");
		nLoseTimes = m_pStore->GetItemLong(0, "losetimes");
		chips = m_pStore->GetItemLong(0, "chip");
		return 0;
	}
	return -1;
}




