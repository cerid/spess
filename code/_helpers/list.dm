/proc/get(list/L)
	if(!L)
		L = list()
	return L

/proc/pop(list/L)
	if(!L || !L.len)
		return
	. = L[L.len]
	--L.len

//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, L.len+1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,L.len+1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex+1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex+1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i=0, i<len, ++i)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex+1)

//Move elements from [fromIndex, fromIndex+len) to [toIndex, toIndex+len)
//Move any elements being overwritten by the move to the now-empty elements, preserving order
//Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swapRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len > distance)	//there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(fromIndex < toIndex)
			toIndex += len
		else
			fromIndex += len

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(toIndex > fromIndex)
			var/a = toIndex
			toIndex = fromIndex
			fromIndex = a

		for(var/i=0, i<len, ++i)
			L.Swap(fromIndex++, toIndex++)

//replaces reverseList ~Carnie
/proc/reverseRange(list/L, start=1, end=0)
	if(L.len)
		start = start % L.len
		end = end % (L.len+1)
		if(start <= 0)
			start += L.len
		if(end <= 0)
			end += L.len + 1

		--end
		while(start < end)
			L.Swap(start++,end--)

	return L


//return first thing in L which has var/varname == value
//this is typecaste as list/L, but you could actually feed it an atom instead.
//completely safe to use
/proc/getElementByVar(list/L, varname, value)
	varname = "[varname]"
	for(var/datum/D in L)
		if(D.vars.Find(varname))
			if(D.vars[varname] == value)
				return D


/proc/checkIfAssociative(list/L)
	if(!istype(L) || !L.len)
		return 0
	for(var/thing in L)
		if(isnum(thing))
			return 0
		if(L[thing] != null)
			return 1
	return 0

/client/verb/testCheck()
	var/list/L = vars
	OOC("[L[1]] = [L[L[1]]]")
	OOC("[checkIfAssociative(L)]")