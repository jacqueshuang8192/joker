#include <stdio.h>
#include "mutex.h"


Mutex::Mutex()
{
	pthread_mutex_init(&m_mutex, NULL);
}


Mutex::~Mutex()
{
	pthread_mutex_destroy(&m_mutex);
}


int Mutex::Lock()
{
	return pthread_mutex_lock(&m_mutex);
}


int Mutex::TryLock()
{
	return pthread_mutex_trylock(&m_mutex);
}


void Mutex::UnLock()
{
	pthread_mutex_unlock(&m_mutex);
}

