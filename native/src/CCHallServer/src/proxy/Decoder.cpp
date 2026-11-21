#include "Decoder.h"
#include "global.h"
#include "ICHAT_PacketBase.h"
#include "log.h"

USING_HTTP_SVR_NS

int HandleInput(const char* data,  int len,int& pty)
{
	int headLen = sizeof(struct QE2Header);
	if(len < headLen)
	{
        log_debug("HandleInput pkg len<headLen,len:%d,headLen:%d data=0x%x,0x%x,0x%x,0x%x\n",len,headLen,data[0],data[1],data[2],data[3]);
		return 0;
	}
	QE2Header *pHeader = (struct QE2Header*)data;
    pty=T_PROTOTYPE_UNKNOW;
    if(pHeader->flag[0]=='B' && pHeader->flag[1]=='Y')
    {
        pty=T_PROTOTYPE_QE;
    }
    else if(pHeader->flag[0]=='Q' && pHeader->flag[1]=='E')
    {
        pty=T_PROTOTYPE_QE2;
    }
	if(pty==T_PROTOTYPE_UNKNOW)
	{
        log_debug("HandleInput Packet Error, data=0x%x,0x%x,0x%x,0x%x\n",data[0],data[1],data[2],data[3]);
		return -1;
	}
	int pkglen = sizeof(int) + ntohl(pHeader->length);
	//log_debug("client packet body length:[%d], cmd:[0x%x]", ntohl(pHeader->length), ntohl(pHeader->cmd));
	if(pkglen<0 || pkglen>10*1024)
	{
        log_debug("HandleInput Packet Error, pkglen=%d\n",pkglen);
		return -1;
	}

	if(len < pkglen)
	{
		return 0;
	}
	return pkglen;
}

