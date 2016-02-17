/object_model
	var/list/attributes = list()
	var/path

	proc/Create(turf/T)
		DMM.preLoader = src
		new path(T)

	proc/Apply(atom/A)
		for(var/varname in attributes)
			A.vars[varname] = attributes[varname]

/map_model
	var/list/gridModels
	var/list/zLevels
	var/keyLen

	Init()
		gridModels = list()
		zLevels = list()

	proc/Apply(_x,_y,_z,alignment=NORTHWEST)
		ASSERT(keyLen)
		ASSERT(gridModels.len)

		var/object_model/M
		var/turf/T

		var/depth = length(zLevels)
		ASSERT(depth)
		var/height = length(zLevels[1])
		ASSERT(height)
		var/width = zLevels[1][1]
		ASSERT(width)

		if(alignment & UP|DOWN)
			_x -= round(width/2)
			_y += round(height/2)
		else
			if(alignment & SOUTH)
				_y += height
			if(alignment & EAST)
				_x -= width

		ASSERT(_x > 0 && _x+width <= world.maxx)
		ASSERT(_y-height > 0 && _y <= world.maxy)
		ASSERT(_z > 0 && _z+depth <= world.maxz)

		var/x=_x
		var/y=_y
		var/z=_z
		for(var/zLevel in zLevels)
			for(var/row in zLevel)
				for(var/tile in row)
					T = locate(x,y,z)
					for(M in tile)
						M.Create(T)
					++x
				x = _x
				++y
			y = _y
			++z

//atom creation method that preloads variables at creation
/atom/New()
	if(DMM.preLoader && (type == DMM.preLoader.path))//in case the instanciated atom is creating other atoms in New()
		DMM.preLoader.Apply(src)

	. = ..()



/controller/parser/dmm
	var/map_model/map
	//var/list/gridModels = list()
	//var/list/zLevels = list()
	//var/keyLen = 0
	var/object_model/preLoader

	Init(_raw)
		i = 1
		raw = _raw
		if(!map)
			map = new()
		map.Init()
		//gridModels = list()
		//zLevels = list()
		//keyLen = 0

