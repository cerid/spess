
	proc/ReadVarname()
	proc/ReadValue()	//identify what type of value we have at position i, and call the appropriate ReadX() proc
	proc/ReadList()			//read a list enclosed in list( and )
	proc/ReadType()			//read a typepath consisting of alphanumeric underscore, hypens and slashes only
	proc/ReadBoolean()


	proc/ReadNull()			//read null
		if(Token() == 110)
			if(findtextEx(raw,"null",i,i+4))
				i += 4
				return null
		throw EXCEPTION("Invalid null: \"[copytext(raw,i,i+4)]\"")


	proc/ReadString()		//read a string enclosed in unescaped quotes
		if(Token() != 34)	//doublequote " - start of string
			throw EXCEPTION("Expected token(34); Recieved token([Token()]) at pos([i])")
		var/last = ++i
		while(1)
			switch(text2ascii(raw,i))
				if(92)	//backslash - skip next character (escaped)
					++i
				if(10,0)	//EOL, EOF - strings cannot contain newlines or end of file markers
					throw EXCEPTION("Unexpected EOL/EOF within string at pos([i])")
				if(34)	//quote - end of string
					break
			++i
		. = copytext(raw,last,i++)
		return .


	proc/ReadNumber()		//read a number containing only numeric characters and a decimal - does not support #IND #INF or #NAN
		switch(Token())
			if(48 to 57,45)
			else
				throw EXCEPTION("Expected token(48-57,45,43); Recieved token([Token()]) at pos([i])")

		var/last = i
		var/decimals = 0
		var/scientific = 0
		while(1)
			switch(text2ascii(raw,++i))
				if(48 to 57)
					continue
				if(46)	//dot - decimal notation
					if(decimals++)
						break
				if(101)	//e - scientific notation
					if(scientific++)
						break
					++decimals
					switch(text2ascii(raw,i+1))
						if(45,43)
							++i
						else
							break
				else
					break
		return text2num(copytext(raw,last,i))



