//Ïß³ÌËø
#ifndef __MUTEX_H
#define __MUTEX_H

#include <pthread.h>

class Mutex
{
public:
	Mutex();
	~Mutex();

public:
	int Lock();
	int TryLock();

	void UnLock();

private:
	pthread_mutex_t m_mutex;
};

#endif
