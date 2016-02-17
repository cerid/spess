//var/controller/parser/Parser = new() // A namespace for procs.

/controller/parser
	var/i = 1
	var/raw

	proc/Decode()	//text -> data

	proc/Encode()	//data -> text

	proc/Load(filename)
		var/text = file2text(filename)
		if(!text)
			throw EXCEPTION("Cannot load file([filename]) or no data present")

		try
			. = Decode(text)
		catch(var/exception/E)
			E.name = "Cannot decode file([filename]):\n[E.name]"
			throw(E)
		return .

	proc/Save(data, filename)
		var/text
		try
			text = Encode(data)
		catch(var/exception/E)
			throw(E)

		if(fexists(filename) && !fdel(filename))
			throw EXCEPTION("Could not delete file([filename])")

		if(!text2file(text,filename))
			throw EXCEPTION("Could not write to file([filename])")

	proc/Token()
		while(1)
			. = text2ascii(raw,i)
			switch(.)
				if(32,9,10)	//whitespace
					++i
					continue
				else
					return .

