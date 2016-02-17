	Decode(_raw)
		Init(_raw)

		//generate gridModels
		var/varname
		var/gridModelKey

		var/list/L			//list of gridModels on a tile
		var/object_model/M
		var/list/gridModels = map.gridModels	//make local
		while(1)
			if(Token() == 40)	//openbracket - reached map portion
				break

			//read gridModelKey
			gridModelKey = ReadString()
			if(!gridModelKey)
				throw EXCEPTION("Invalid gridModelKey([gridModelKey]) at pos([i])")

			//locate equals preceeding model data
			if(Token() != 61)	//equals - required
				throw EXCEPTION("Expected token(61); Recieved token([Token()]) at pos([i])")
			++i	//move cursor past equals

			if(Token() == 40)	//openbracket - multiple object models on tile
				++i	//move cursor past openbracket

			//initialize our list to contain grid model data
			L = list()
			gridModels[gridModelKey] = L

			while(1)
				M = new()
				M.path = ReadType()
				L.Add(M)

				switch(Token())
					if(44)	//comma - proceed to next object
						continue
					if(123)	//openbrace { - attributes provided for current object
					else
						break

				//gather attributes data if we get this far (see above)
				while(1)
					varname = ReadVarname()
					if(!varname)
						throw EXCEPTION("Invalid object variable([varname]) at pos([i])")

					//locate equals preceeding variable's associated value
					if(Token() != 61)	//equals - required
						throw EXCEPTION("Expected token(61); Recieved token([Token()]) at pos([i])")
					++i	//move cursor past equals

					M.attributes[varname] = ReadValue()

					switch(Token())
						if(59)	//semicolon - proceed to next attribute
							continue
						if(125)	//closebrace - end of object attributes
							++i
							break

					throw EXCEPTION("Expected token(59,125); Recieved token([Token()]) at pos([i])")

				if(Token() != 44)	//if not comma - don't read next object
					break

		if(gridModels.len < 1)
			throw EXCEPTION("No gridModels generated")
		map.keyLen = length(gridModels[1])
		if(map.keyLen < 1)
			throw EXCEPTION("Invalid gridModel key")

		//generate zLevels
		var/list/Z
		var/list/R
		var/list/zLevels = map.zLevels	//make local
		var/keyLen = map.keyLen

		while(1)
			i = findtextEx(raw,"{\"\n",i,0)
			if(!i)
				break
			i += 3
			Z = list()
			R = list()

			while(1)
				switch(text2ascii(raw,i))
					if(65 to 90, 97 to 122)
						gridModelKey = copytext(raw,i,i+keyLen)
						L = gridModelKey	//gridModels[gridModelKey]
						//world << "[gridModelKey] at [i]"
						ASSERT(L)

						R[++R.len] = L
						i += keyLen
					if(10)
						//Z.Insert(1,null)
						//Z[1] = R
						Z[++Z.len] = R
						R = list()
						++i
					if(34)
						zLevels[++zLevels.len] = Z
						++i
						break
					else
						throw EXCEPTION("Expected token(65-90,97-122,10,34); Recieved token([text2ascii(raw,i)]) at pos([i])")


		return map




	ReadVarname()
		var/last = i
		while(1)
			switch(text2ascii(raw,++i))
				if(48 to 57, 65 to 90, 97 to 122, 95, 45)	//acceptable characters
					continue
				else	//end of varname
					return copytext(raw,last,i++)

	ReadValue()
		switch(Token())
			if(48 to 57, 45)	//0-9 or minus - numeric
				return ReadNumber()
			if(34)	// " - precedes a string
				return ReadString()
			if(108)	// l - for list
				return ReadList()
			if(47)	// / - typepath
				return ReadType()
			if(110)	// n - for null
				return ReadNull()
		throw EXCEPTION("Unsupported value type")

	ReadList()
		if(Token() != 108 || !findtextEx(raw,"list(",i,i+5))
			throw EXCEPTION("Invalid start of list([copytext(raw,i,i+5)]) at pos([i])")

		i += 5	//move cursor past list( preface

		var/list/L = list()
		var/value

		if(Token() == 41)	//closebracket - end of list
			++i
			return L

		while(1)
			value = ReadValue()

			switch(Token())
				if(41)	//closebracket - end of list
					++i
					L[++L.len] = value
					break
				if(61)	//equals - associative list
					++i
				if(44)	//comma - proceed to next element in list
					++i
					L[++L.len] = value
					continue
				else
					throw EXCEPTION("Expected token(41,44,61); Recieved token([Token()]) at pos([i])")

			L[value] = ReadValue()
			switch(Token())
				if(41)	//closebracket - end of list
					break
				if(44)	//comma - proceed to next element in list
					continue
				else
					throw EXCEPTION("Expected token(41,44); Recieved token([Token()]) at pos([i])")

		return L

	ReadType()
		if(Token() != 47)
			throw EXCEPTION("Expected token(47); Recieved token([Token()]) at pos([i])")

		var/last = i
		while(1)
			switch(text2ascii(raw,++i))
				if(47 to 57, 65 to 90, 97 to 122, 95, 45)	//acceptable characters
					continue
			break
		. = text2path(copytext(raw,last,i))
		if(. == null)
			throw EXCEPTION("Invalid typepath([copytext(raw,last,i)]) at pos([last])")
		return .