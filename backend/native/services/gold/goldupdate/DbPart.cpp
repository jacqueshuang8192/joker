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
	VLogMsg(CLIB_LOG_LEV_INFO, "CallProcedure error:[%s]", m_strError.c_str());
	return FALSE;
}

int CDbPart::UpdateData(int uid,const UserInfo & data)
{
	char szSql[1000] = {0};
	
	VLogMsg(CLIB_LOG_LEV_INFO, "UpdateData [%d] [%d] [%d] [%d]", data.addchips, data.chip, uid, data.needUpdateChips);
	int chips = data.chip;
	if (data.needUpdateChips == 2)//需要修正chips值，改为0
	{
		chips = 0;
	}
	
	snprintf(szSql, sizeof(szSql), "update bullfight_gameinfo%d set exp=%d, score=%d, money=%ld,wintimes=%d, losetimes=%d,chip=%d where mid=%d", GetTableIndex(uid), data.exp, data.score, data.money, data.win, data.lose, chips, uid);
	CallProcedure(szSql);
	return 0;
}

int CDbPart::UpdateChipData(int uid, int chips, int addChips, int activityID)
{
	char szSql[1000] = { 0 };
	VLogMsg(CLIB_LOG_LEV_INFO, "UpdateChipData [%d] [%d] [%d] [%d]", uid, chips, addChips, activityID);
	if (addChips == 0)
	{
		snprintf(szSql, sizeof(szSql), "update t_activity_user set present_chip=%d where userid=%d and activity_id=%d", chips, uid, activityID);

		CallProcedure(szSql);
		return 0;
	}
	
	snprintf(szSql, sizeof(szSql), "update t_activity_user set bring_chip=%d, present_chip=%d where userid=%d and activity_id=%d", addChips, chips, uid, activityID);

	CallProcedure(szSql);
	VLogMsg(CLIB_LOG_LEV_INFO, "UpdateChipData enter");
	return 0;
}

