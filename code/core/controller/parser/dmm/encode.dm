	Encode()
		if(map.keyLen < 1)
			throw EXCEPTION("No keyLen")
		if(length(map.zLevels) < 1)
			throw EXCEPTION("No zLevels data")

		. = ""

		var/object_model/M
		var/list/L
		var/varname
		var/j
		var/k
		//write gridModels
		var/list/gridModels = map.gridModels	//make local
		for(var/key in gridModels)
			. += "[WriteString(key)] = "
			L = gridModels[key]
			if(L.len > 1)
				. += "("

			k=0
			for(M in L)
				. += WriteType(M.path)
				if(M.attributes.len)
					. += "{"
					j = 0
					for(varname in M.attributes)
						. += "[WriteVarname(varname)] = [WriteValue(M.attributes[varname])]"
						if(++j < M.attributes.len)
							. += "; "
					. += "}"
				if(++k < L.len)
					. += ","

			if(L.len > 1)
				. += ")"
			. += "\n"

		//write
		var/z = 0
		var/list/zLevels = map.zLevels	//make local
		for(var/zLevel in zLevels)
			. += "\n(1,1,[++z]) = {\"\n"
			for(var/row in zLevel)
				for(var/tile in row)
					. += tile
				. += "\n"
			. += "\"}"


	WriteVarname(varname)
		return "[varname]"

	WriteValue(val)
		if(isnum(val))
			return WriteNumber(val)
		if(istext(val))
			return WriteString(val)
		if(istype(val,/list))
			return WriteList()
		if(ispath(val))
			return WriteType(val)
		if(isnull(val))
			return WriteNull()
		throw EXCEPTION("Unsupported value type")

	WriteList(list/L)
		. = "list("
		var/i=0
		for(var/e in L)
			. += WriteValue(e)
			if(!isnum(e))	//assume we are associative
				. += " = [WriteValue(L[e])]"
			if(++i < L.len)
				. += ", "
		. += ")"
		return .

	WriteType(typepath)
		return "[typepath]"