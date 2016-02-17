/proc/repeatText(text, l)
	// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
	#define S1    "[text]"
	#define S4    S1,  S1,  S1,  S1
	#define S16   S4,  S4,  S4,  S4
	#define S64   S16, S16, S16, S16

	if(l <= 1) // Early-out code for empty or singleton lists.
		return l ? S1 : ""

	var/i = 1 // Incremented every time a list index is accessed.

	. = "[text]"

	if(l-1 & 0x01) // 'i' will always be 1 here.
		. += S1 // Append 1 element if the remaining elements are not a multiple of 2.
		++i
	if(l-i & 0x02)
		. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		i += 2
	if(l-i & 0x04)
		. = text("[][][][][]", ., S4) // And so on...
		i += 4
	if(l-i & 0x08)
		. = text("[][][][][][][][][]", ., S4, S4)
		i += 8
	if(l-i & 0x10)
		. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		i += 16
	if(l-i & 0x20)
		. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		i += 32
	if(l-i & 0x40)
		. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		i += 64
	while(l > i) // Chomp through the rest of the list, 128 elements at a time.
		. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)
		i += 128

	#undef S64
	#undef S16
	#undef S4
	#undef S1

proc/replaceTextOnce(text, find, replace)
	var/pos = findtext(text, find)
	if(!pos)
		return text
	var/len = length(find)
	return copytext(text, 1, pos) + replace + copytext(text, pos+len, 0)

proc/replaceTextOnceEx(text, find, replace)
	var/pos = findtextEx(text, find)
	if(!pos)
		return text
	var/len = length(find)
	return copytext(text, 1, pos) + replace + copytext(text, pos+len, 0)

proc/replaceTextEx(text, find, replace)
	var/len = length(find)
	var/pos = findtextEx(text, find)
	var/prev = 1
	while(pos)
		. += copytext(text,prev,pos) + replace
		prev = pos + len
		pos = findtextEx(text,find,prev)
	. += copytext(text,prev,0)
	return .

proc/replaceText(text, find, replace)
	var/len = length(find)
	var/pos = findtext(text, find)
	var/prev = 1
	while(pos)
		. += copytext(text,prev,pos) + replace
		prev = pos + len
		pos = findtext(text,find,prev)
	. += copytext(text,prev,0)
	return .