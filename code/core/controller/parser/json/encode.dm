	Encode(data, inline=0)
		raw = ""
		i = 1
		indent = inline ? "" : "\n"
		return WriteObject(data)

	proc/WriteObject(list/L)
		. = "{"

		if(indent)	indent += "\t"

		var/key
		for(var/i=1, i<=L.len, ++i)
			. += "[indent]"
			key = L[i]
			. += "[WriteVarname(key)]:[indent ? "" : " "][WriteValue(L[key])][i<L.len ? "," : ""]"
		if(indent)	indent = copytext(indent, 1, -1)
		. += "[indent]}"

	WriteVarname(key)
		return WriteString(key)

	WriteValue(value)
		if(isnum(value))
			return WriteNumber(value)
		if(istext(value))
			return WriteString(value)
		if(isnull(value))
			return WriteNull()
		if(istype(value, /list))
			if(checkIfAssociative(value))
				//newassociative object
				return WriteObject(value)
			return WriteList(value)
		throw EXCEPTION("Unsupported value type [value]")

	WriteBoolean(value)
		if(value)
			return "true"
		else
			return "false"


	WriteList(list/L)
		. = "\["
		var/i=0
		for(var/e in L)
			. += WriteValue(e)
			if(++i < L.len)
				. += ", "
		. += "\]"
		return .