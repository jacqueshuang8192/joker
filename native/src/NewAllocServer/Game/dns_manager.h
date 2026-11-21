#ifndef __DNS_MANAGER_H
#define __DNS_MANAGER_H

#include <map>
#include <string>
using namespace std;

#include "mutex.h"

#include <netinet/in.h>

class DNSManager
{
public:
	DNSManager();
	virtual ~DNSManager();

public:
	static DNSManager* GetSingleton();

	void AddIpAddr(const char *domain, const struct sockaddr_in &addr);

	bool GetIpAddr(const char *domain, struct sockaddr_in &addr);

private:
	map<string, struct sockaddr_in> m_ipaddr_dict;
	Mutex m_mutex;
};


#endif
