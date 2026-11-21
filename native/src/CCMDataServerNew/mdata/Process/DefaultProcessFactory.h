#pragma once
#include "ProcessFactory.h"

class DefaultProcessFactory:public ProcessFactory{
	public:
		virtual IProcess* createProcesser(int cmd);
};

