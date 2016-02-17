/*
/dmm_suite/object_model
	var/typepath
	var/attributes = list()
*/
/dmm_suite/tile_model
	var/list/paths = list()
	var/list/attributes = list()

/*
	Init(rawText)
		..()

		var/Li = 1
		var/len = length(rawText)

		var/state = 0	//0=nodata; 1=readingpath; 2=readingattrib
		var/val

		var/list/L

		for(var/Ri=1, Ri<=len, ++Ri)
			switch(text2ascii(rawText,Ri))

				if(92)	//backslash, skip next character
					if(state >= 2)
						++Ri
						continue

				if(47)	//slash, start of path
					if(state < 1)
						state = 1

				if(44)	//comma
					if(state == 1)
						val = text2path(copytext(rawText,Li,Ri))
						if(val)
							paths.Add(val)
							attributes.Add(null)
						state = 0

				if(123)	//left parenthesis {
					if(state == 1)
*/
#define FIND_KEY -1
#define SUCCESS 0

#define READ_KEY 1

#define FIND_PATH 2
#define READ_PATH 3

#define FIND_VAR 4
#define READ_VAR 5

#define FIND_VAL 6
#define READ_VALNUM 7
#define READ_VALTXT 8
#define READ_VALPATH 9
#define READ_VALNULL 10

#define READ_MAPCOORD 20
#define READ_MAP 21


/dmm_suite/map_preloader
	var/keySize = 0
	var/list/keys = list()

	var/state = FIND_KEY
	var/map
	var/mapWidth = 0

	var/x = 1
	var/y = 1
	var/z = 1

	proc/Load(filename)
		state = FIND_KEY

		ASSERT(filename)
		ASSERT(istext(filename))
		ASSERT(fexists(filename))

		var/raw = file2text(filename)
		ASSERT(raw)


		var/i = 0
		var/Li
		var/Ri
		var/ascii

		var/key
		var/varname
		var/val
		var/path
		var/list/L

		keySize = 0
		keys.Cut()
		map = null

		var/dmm_suite/tile_model/M

		while(1)
			ascii = text2ascii(raw, ++i)
			if(!ascii)
				break

			switch(state)
				if(FIND_KEY)
					switch(ascii)
						if(34)	//quote
							state = READ_KEY
							Li = i+1
						if(10)	//newline
							continue
						if(40)	//open bracket
							state = READ_MAPCOORD
						else
							CRASH("Invalid character encountered at start of line")

				if(READ_KEY)
					switch(ascii)
						if(34)	//quote
							state = FIND_PATH
							Ri = i
							key = copytext(raw, Li, Ri)
							ASSERT(key)

							M = new()
							keys[key] = M
						if(65 to 90)	//A-Z
						if(97 to 122)	//a-z
						else
							CRASH("Invalid character encountered within key")

				if(FIND_PATH)
					switch(ascii)
						if(32,61,40,44,41)	//space, equals, open bracket, comma, close bracket
							continue
						if(47)	//slash
							//start reading object path
							state = READ_PATH
							Li = i
						if(10)	//newline
							state = FIND_KEY
						else
							CRASH("Invalid character encountered preceding typepath")

				if(READ_PATH)
					switch(ascii)
						if(65 to 90)	//A-Z
						if(97 to 122)	//a-z
						if(48 to 57)	//0-9
						if(95,47,45)		//underscore, slash, hyphen
						if(44,123)	//comma, open-brace
							//end reading object path
							Ri = i
							path = text2path(copytext(raw,Li,Ri))
							ASSERT(path)

							M.paths.Add(path)
							if(ascii == 44)	//comma
								state = FIND_PATH
								M.attributes.Add(null)
								continue

							state = FIND_VAR
							L = list()

						else
							CRASH("Invalid character encountered within typepath")

				if(FIND_VAR)
					switch(ascii)
						if(59,32)	//semicolon, space
						if(65 to 90, 97 to 122)	//A-Z, a-z
							state = READ_VAR
							Li = i+1
						if(125)	//close brace
							state = FIND_KEY
							M.attributes.Add(null)
						else
							CRASH("Invalid character encountered preceding varname")

				if(READ_VAR)
					switch(ascii)
						if(65 to 95, 97 to 122, 48 to 57)	//alphanumeric
						else
							Ri = i
							varname = copytext(raw,Li,Ri)
							ASSERT(varname)
							state = FIND_VAL

				if(FIND_VAL)
					switch(ascii)
						if(32,61)	//space, equals
						if(48 to 57)	//numeric
							state = READ_VALNUM
							Li = i
						if(110)	//null
							state = READ_VALNULL
						if(34)	//quote
							state = READ_VALTXT
							Li = i+1
						if(47)	//slash
							state = READ_VALPATH
							Li = i
						if(108)	//list
							state = READ_VALLIST
							//TODO
						else
							CRASH("Invalid character encountered preceding value")


				if(READ_VALNUM)
					switch(ascii)
						if(48 to 57, 46, 45)
						else
							state = FIND_VAR
							Ri = i
							val = text2num(copytext(raw,Li,Ri))
							ASSERT(val != null)

				if(READ_VALTXT)

				if(READ_VALPATH)

				if(READ_VALNULL)
					switch(ascii)
						if(108,110,117)
						else
							val = null





/*

	proc/Load(filepath)
		mapWidth = 0
		mapHeight = 0

		zModels.Cut()

		ASSERT(filepath)
		ASSERT(istext(filepath))
		ASSERT(fexists(filepath))
		var/raw = file2text(filepath)
		ASSERT(raw)

		var/list/gridModels = list()	//"aaa" = grid_model object
		//var/list/gridModelsRaw = list()	//"aaa"="/path{varname=val;varname2=val2},/path2,/path3" etc.
		var/modelKey = 0
		var/modelContents
		var/modelKeyLen

		//gather gridModelsRaw text
		var/Li = 1
		var/Ri = 0
		while(1)
			if(text2ascii(raw,Li) != 34)	//quote
				break	//we reached the map "layout"
			if(modelKeyLen)
				Ri = Li+modelKeyLen	//at closing quote of key
			else
				Ri = findtextEx(raw,"\"", Li+1, 0)
				ASSERT(Ri)
				modelKeyLen = (Ri-Li)-1
			modelKey = copytext(raw, Li, Ri)
			ASSERT(modelKey)
			Li = Ri+4
			Ri = findtextEx(raw,"\n",Li,0)
			ASSERT(Ri)
			if(text2ascii(raw,Li) == 40)
				modelContents = copytext(raw,Li+1,Ri-1)
			else
				modelContents = copytext(raw,Li,Ri)
			gridModels[modelKey] = new /dmm_suite/grid_model(modelContents)

			++Ri
			sleep(-1)

		ASSERT(gridModels.len)	//there must be some models

		//var/list/zModelsRaw = list()	//zlevel
		//var/zLine = ""

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

*/





