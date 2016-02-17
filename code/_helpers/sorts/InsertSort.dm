//simple insertion sort - generally faster than merge for runs of 7 or smaller
/proc/sortInsert(list/L, cmp=/proc/cmp_numeric_asc, associative, fromIndex=1, toIndex=0, headStart)
	if(L && L.len >= 2)
		if(!headStart)
			headStart = fromIndex
		fromIndex = fromIndex % L.len
		toIndex = toIndex % (L.len+1)
		headStart = headStart % L.len
		if(fromIndex <= 0)
			fromIndex += L.len
		if(toIndex <= 0)
			toIndex += L.len + 1
		if(headStart <= 0)
			headStart += L.len

		Sort.Init(L,cmp,associative)
		Sort.Binary(fromIndex, toIndex, headStart)
	return L