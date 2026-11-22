#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dns_manager.h"

DNSManager::DNSManager()
{

}

DNSManager::~DNSManager()
{

}

DNSManager* DNSManager::GetSingleton()
{
	static DNSManager s_singleton;
	return &s_singleton;
}

void DNSManager::AddIpAddr(const char *domain, const struct sockaddr_in &addr)
{
	if (domain == NULL)
	{
		return;
	}

	m_mutex.Lock();

	m_ipaddr_dict[domain] = addr;

	m_mutex.UnLock();
}

bool DNSManager::GetIpAddr(const char *domain, struct sockaddr_in &addr)
{
	if (domain == NULL)
	{
		return false;
	}

	m_mutex.Lock();

	map<string, struct sockaddr_in>::iterator itr = m_ipaddr_dict.find(domain);
	if (itr != m_ipaddr_dict.end())
	{
		struct sockaddr_in &target_addr = itr->second;
		addr = target_addr;

		m_mutex.UnLock();
		return true;
	}
	m_mutex.UnLock();

	return false;
}

