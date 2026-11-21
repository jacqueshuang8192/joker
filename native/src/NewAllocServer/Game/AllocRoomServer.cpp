
#include "MainServer.h"
int main(int argc, char *argv[])
{
	MainServer server;
	if(server.start(argc, argv) == -1)
		return -1 ;
	return server.waitForShutdown();
}
