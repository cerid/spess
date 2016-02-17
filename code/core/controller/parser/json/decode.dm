	//Decode _raw json-formatted text into an associative key=value list
	Decode(_raw)
		raw = _raw
		i = 1
		return ReadObject()

	//read an associative-list object nested within braces { }
	proc/ReadObject()
		if(Token() != 123)	//open-brace - new associative list
			throw EXCEPTION("Expected token(123); Recieved token([Token()]) at pos([i])")
		++i	//move cursor past {

		var/list/L = list()

		var/key
		var/value
		while(1)
			//read varname portion
			key = ReadVarname()
			if(!key)
				throw EXCEPTION("Invalid key([key])")

			//locate required colon indicating value associated to key
			if(Token() != 58)	//colon
				throw EXCEPTION("Expected token(58); Recieved token([Token()]) at pos([i])")
			++i	//move cursor to character after colon

			try
				value = ReadValue()	//attempt to read value portion
			catch(var/exception/E)
				throw(E)

			L[key] = value

			switch(Token())
				if(44)	//comma - proceed to next element
					++i	//move cursor past comma
					continue
				if(125)	//close-brace - no more elements, end loop
					++i	//move cursor past closebrace
					break
				else
					throw EXCEPTION("Expected token(44 or 125); Recieved token([Token()]) at pos([i])")
		return L


	ReadVarname()
		return ReadString()


	ReadValue()
		switch(Token())
			if(58)	//open-brace - associative list object
				return ReadObject()
			if(48 to 57)	//0-9 or . - numeric
				return ReadNumber()
			if(34)	// " - precedes a string
				return ReadString()
			if(91)	// [ - for array(non-associative list)
				return ReadList()
			if(110)	// n - for null
				return ReadNull()
			if(102,116)	//t,f - Boolean
				return ReadBoolean()
		throw EXCEPTION("Unsupported value type at pos([i])")


	ReadBoolean()
		switch(Token())
			if(116)	//t - true
				if(findtextEx(raw,"true",i,i+4))
					i += 4
					return TRUE
				throw EXCEPTION("Invalid boolean: \"[copytext(raw,i,i+4)]\"")
			if(102)	//f - false
				if(findtextEx(raw,"false",i,i+5))
					i += 5
					return FALSE
				throw EXCEPTION("Invalid boolean: \"[copytext(raw,i,i+5)]\"")
		throw EXCEPTION("Expected token(102 or 116); Recieved token([Token()]) at pos([i])")



	ReadList()
		if(Token() != 91)	//open squarebracket [ - new non-associative list
			throw EXCEPTION("Expected token(91); Recieved token([Token()]) at pos([i])")
		++i	//move cursor past [

		var/list/L = list()
		while(1)
			L[++L.len] = ReadValue()

			switch(Token())
				if(44)	//comma - proceed to next element
					++i
					continue
				if(93)	//close-squarebracket - no more elements. end loop
					++i
					break
				else
					throw EXCEPTION("Expected token(44 or 93); Recieved token([Token()]) at pos([i])")

		return L