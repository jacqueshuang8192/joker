#pragma once
#include "CCStreamDecoder.h"

class CCLandlordDecoder : public CCStreamDecoder
 {
	public:
		CCLandlordDecoder(){};
		virtual ~CCLandlordDecoder(){};
		 
	protected:
 
		virtual inline int GetHeadLen(const char * data, int len)
		{
			(void)len;
			return sizeof(TPkgHeader) ;
		}
		
		virtual inline  int GetPacketLen(const char * data, int len)
		{
			(void)len;
			struct TPkgHeader* pHeader = (struct TPkgHeader*) data;
			int pkglen = sizeof(int) + ntohl(pHeader->length); 
			if((unsigned int)pkglen < sizeof(TPkgHeader) || pkglen>10240)
				return -1;
			else
				return pkglen;
		}

		virtual inline  bool CheckHead(const char * data, int len)
		{
			(void)len;
			struct TPkgHeader* pHeader = (struct TPkgHeader*) data;
			if(pHeader->flag[0] == 'B' && pHeader->flag[1] == 'Y')
				return true;
			else
				return false;
		} 
};

