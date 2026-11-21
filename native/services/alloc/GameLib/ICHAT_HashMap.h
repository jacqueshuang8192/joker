#pragma once
#include "ace/Hash_Map_Manager_T.h"

template<class EXT_ID, class INT_ID, ACE_SYNCH_DECL = ACE_Null_Mutex>
class ICHAT_Hash_Map:
	public ACE_Hash_Map_Manager_Ex<EXT_ID, INT_ID,
	ACE_Hash<EXT_ID>, ACE_Equal_To<EXT_ID>, ACE_SYNCH_USE>
{};
