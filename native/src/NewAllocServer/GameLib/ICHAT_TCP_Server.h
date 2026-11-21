#pragma once
#include "ichatlib.h"
#include "ace/Acceptor.h"
#include "ace/SOCK_Acceptor.h"

#include "ICHAT_TCP_Handler.h"

class ICHAT_TCP_Server:public ACE_Acceptor<ICHAT_TCP_Handler<>, ACE_SOCK_ACCEPTOR>
{
public:
	ICHAT_TCP_Server(void);
	~ICHAT_TCP_Server(void);

public:
	// ¶¯Ì¬´´½¨Handler
	virtual ICHAT_TCP_Handler<> * CreateHandler(void) = 0;

private:
	int make_svc_handler(ICHAT_TCP_Handler<> *&);
};
