#include "ICHAT_TCP_Server.h"

ICHAT_TCP_Server::ICHAT_TCP_Server(void)
{
}

ICHAT_TCP_Server::~ICHAT_TCP_Server(void)
{
}

////////////////////////////////////////////////////////////////////////////////
// make_svc_handler
////////////////////////////////////////////////////////////////////////////////
int ICHAT_TCP_Server::make_svc_handler(ICHAT_TCP_Handler<> *&sh)
{

	//ACE_DEBUG((LM_INFO, ACE_TEXT("(%P|%t) create handler!!!!!!!\r\n")));
	sh = (ICHAT_TCP_Handler<>*)this->CreateHandler();

	if(sh == NULL)
	{
		ACE_SOCK_Stream peer;
		if(this->acceptor().accept(peer) == -1)
			return -1;
		peer.close();
		return -1;
	}

	sh->reactor(this->reactor());
	sh->server(this);
	return 0;
}
