/dmm_suite/core
	var/mapWidth = 0
	var/mapHeight = 0
	var/list/zModels = list()
	var/modelKeyLen = 0
	var/list/gridModels

	var/j = 0
	var/raw

	proc/Apply(x0, y0, z0)
		var/z = z0
		for(var/dmm_suite/z_model/Z in zModels)
			Z.Apply(x0,y0,z++)

	proc/Load(filepath)
		mapWidth = 0
		mapHeight = 0
		modelKeyLen = 0
		zModels.Cut()

		ASSERT(filepath)
		ASSERT(istext(filepath))
		ASSERT(fexists(filepath))
		raw = file2text(filepath)
		ASSERT(raw)

		GenerateTileModels()
		ASSERT(gridModels.len)	//there must be some models

		//GenerateZModels
		var/Li = 1
		var/Ri = j

		//find start of first zlevel
		Li = findtextEx(raw,"\n(1,1,",Ri,0)
		ASSERT(Li)
		Li = findtextEx(raw,"\n",Li,0)
		ASSERT(Li)
		++Li

		//calculate mapWidth
		Ri = findtextEx(raw,"\n",Li,0)
		ASSERT(Ri)
		var/zLineLen = Ri-Li
		mapWidth = (zLineLen-1) / modelKeyLen
		ASSERT(mapWidth > 0)

		//calculate mapHeight
		Ri = findtextEx(Ri,"\n\"",Ri,0)
		ASSERT(Ri)
		mapHeight = (Ri - Li) / zLineLen
		ASSERT(mapHeight > 0)

		//fill zModels list with zmodels data
		var/x=1
		var/y=1
		var/dmm_suite/z_model/Z
		var/modelKey

		while(1)
			Z = new(mapWidth, mapHeight)

			while(1)
				Ri = Li + mapWidth
				ASSERT(text2ascii(raw,Ri) == 10)

				for(Li, Li<Ri, Li+=modelKeyLen)
					modelKey = copytext(raw,Li,Li+modelKeyLen)
					ASSERT(modelKey)
					Z.layout[y][x] = gridModels[modelKey]
					if(++x > mapWidth)
						x = 1

				Li = Ri+1
				if(text2ascii(raw,Li) < 65)	//quote or null
					break
				++y

			zModels.Add(Z)


	proc/GenerateTileModels()
		gridModels = list()	//"aaa" = grid_model object

		var/dmm_suite/grid_model/M
		var/dmm_suite/atom_model/A
		var/path
		var/varname
		var/value
		var/modelKey

		while(1)
			//get modelKey
			//ASSERT(SeekTo("\""))
			if(text2ascii(raw,j) != 34)
				break
			modelKey = ReadStr()
			ASSERT(modelKey)
			if(!modelKeyLen)
				modelKeyLen = length(modelKey)

			M = new()
			while(1)	//get each object
				//get path
				ASSERT(SeekTo("/"))
				path = ReadPath()
				ASSERT(path)

				A = new()
				A.path = path

				if(text2ascii(raw,j) == 123)
					//attributes data present
					A.attributes = list()
					while(1)
						//read each attribute
						if(!SeekToAlpha())
							break
						varname = ReadVarname()
						ASSERT(varname)

						SeekPast()	//seek past the equals sign and spaces

						value = ReadVal()

						A.attributes[varname] = value

						if(text2ascii(raw,j) == 125)
							break

			gridModels[modelKey] = M
			SeekTo("\n")

		return gridModels


	proc/SeekTo(char)
		j = findtextEx(raw,char,++j,0)
		return j

	proc/SeekToAlpha()
		while(1)
			switch(text2ascii(raw,++j))
				if(97 to 122, 65 to 90)
					break
		return j

	proc/SeekPast()
		while(1)
			switch(text2ascii(raw,++j))
				if(32,61,59)
					continue
				else
					break


	proc/ReadNum()
		var/last = j
		while(1)
			switch(text2ascii(raw,++j))
				if(48 to 57, 46)
					continue
				else
					return text2num(copytext(raw,last,j))

	proc/ReadVarname()
		var/last = j
		while(1)
			switch(text2ascii(raw,++j))
				if(48 to 57, 65 to 90, 97 to 122, 95, 45)	//acceptable characters
					continue
				else	//end of varname
					return copytext(raw,last,j)

	proc/ReadStr()
		var/last = j
		while(1)
			switch(text2ascii(raw,++j))
				if(92)	//backslash - skip escaped character
					++j
				if(34,null,0)
					return copytext(raw,last,j)

	proc/ReadPath()
		var/last = j
		while(1)
			switch(text2ascii(raw,++j))
				if(47 to 57, 65 to 90, 97 to 122, 95, 45)	//acceptable characters
					continue
				else
					return text2path(copytext(raw,last,j))

	proc/ReadVal()
		switch(text2ascii(raw,j))
			if(48 to 57, 46)	//numeric
				return ReadNum()
			if(34)	//string
				return ReadStr()
			if(108)	//list
				return ReadList()
			if(47)	//path
				return ReadPath()
			else
				CRASH("Unrecognised value type")


	proc/ReadList()
		var/list/L = list()
		var/value
		ASSERT(findtextEx(raw,"list(",j,j+5) == j)
		j += 5
		while(1)
			value = ReadVal()
			--j
			SeekPast()
			switch(text2ascii(raw,j))
				if(41)	//close-bracket - end of list
					L.Add(value)
					break
				if(44)	//comma - next list element
					L.Add(value)
					continue
				else
					L[value] = ReadVal()
					switch(text2ascii(raw,j))
						if(41)
							break
						if(44)
							continue
						else
							CRASH("Unrecognised character")

		return L


/dmm_suite/z_model
	var/list/layout

	New(mapWidth, mapHeight)
		layout = new /list(mapHeight, mapWidth)

	proc/Apply(x0,y,z)
		var/dmm_suite/grid_model/M
		var/list/L

		var/x = x0
		var/e
		for(e in layout)
			L = e
			for(e in L)
				M = e
				M.Apply(locate(x,y,z))
				++x
			x = x0
			++y

/dmm_suite/grid_model
	var/list/atomModels = list()

	proc/Apply(turf/T)
		ASSERT(T)
		for(var/e in atomModels)
			e:InstanceAt(T)

/dmm_suite/atom_model
	var/path
	var/list/attributes

	proc/InstanceAt(turf/T)
		new path(T, attributes)

/atom/New(_loc, list/_vars)
	if(_vars && istype(_vars))
		for(var/varname in _vars)
			vars[varname] = _vars[varname]
	return ..()