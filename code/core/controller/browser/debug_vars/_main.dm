
/controller/master
	var/list/dataTypes = list("pointer","text","number","null","default")

/variable_editor
	var/prevDataSrc
	var/dataSrc

	New(_dataSrc, mob/_viewer)
		SetDataSrc(_dataSrc)
		UI(_viewer)

	proc/SetDataSrc(target)
		if(IsViewableInstance(target))
			prevDataSrc = dataSrc
			dataSrc = target
			return 1
		return 0

	UI(mob/viewer, uiID="debug", ui/U, forceOpen=0)
		U = Interface.TryUpdate(viewer, src, uiID, U, forceOpen)
		if(!U)
			U = new(viewer, src, uiID, "debug", "DEBUG::\ref[dataSrc]", 460, 515)
			U.Open()

	CanInteract()
		if(IsViewableInstance(dataSrc))
			return UI_INTERACTIVE
		return UI_CLOSE

	Topic(href, list/L, ui_state/state)
		switch(L["action"])
			if("debug")
				var/ref = L["ref"]
				if(ref)
					if(SetDataSrc(locate(ref)))
						return 1

				var/varname = L["varname"]
				if(varname && hasVar(dataSrc, varname))
					return SetDataSrc(dataSrc:vars[varname])

			if("edit")
				var/varname = L["varname"]
				if(varname)
					return Edit(varname)
		return 0

	GetUIData(mob/viewer)
		var/list/L = list()	//vars
		. = list("ref"="\ref[dataSrc]","vars"=L)	//header data

		if(istype(dataSrc,/list))
			var/associative = checkIfAssociative(dataSrc)
			//.["mode"] = associative ? "associative" : "non-associative"
			var/i=0
			if(associative)
				for(var/thing in dataSrc)
					L["[++i]"] = list(Convert(thing), Convert(dataSrc[thing]))
			else
				for(var/thing in dataSrc)
					L["[++i]"] = list(Convert(thing))
			return

		if(istype(dataSrc,/datum) || istype(dataSrc,/client))
			//.["mode"] = "datum"
			for(var/varname in dataSrc:vars)
				L[varname] = Convert(dataSrc:vars[varname])
			return

		if(dataSrc == world)
			//.["mode"] = "datum"
			L["address"] = Convert(world.address)
			L["area"] = Convert(world.area)
			L["cache_lifespan"] = Convert(world.cache_lifespan)
			L["contents"] = Convert(world.contents)
			L["cpu"] = Convert(world.cpu)
			L["executor"] = Convert(world.executor)
			L["fps"] = Convert(world.fps)
			L["game_state"] = Convert(world.game_state)
			L["host"] = Convert(world.host)
			L["hub"] = Convert(world.hub)
			L["hub_password"] = Convert(world.hub_password)
			L["icon_size"] = Convert(world.icon_size)
			L["internet_address"] = Convert(world.internet_address)
			L["log"] = Convert(world.log)
			L["loop_checks"] = Convert(world.loop_checks)
			L["map_format"] = Convert(world.map_format)
			L["maxx"] = Convert(world.maxx)
			L["maxy"] = Convert(world.maxy)
			L["maxz"] = Convert(world.maxz)
			L["mob"] = Convert(world.mob)
			L["name"] = Convert(world.name)
			L["params"] = Convert(world.params)
			L["port"] = Convert(world.port)
			L["realtime"] = Convert(world.realtime)
			L["reachable"] = Convert(world.reachable)
			L["sleep_offline"] = Convert(world.sleep_offline)
			L["status"] = Convert(world.status)
			L["system_type"] = Convert(world.system_type)
			L["tick_lag"] = Convert(world.tick_lag)
			L["turf"] = Convert(world.turf)
			L["time"] = Convert(world.time)
			L["timeofday"] = Convert(world.timeofday)
			L["url"] = Convert(world.url)
			L["version"] = Convert(world.version)
			L["view"] = Convert(world.view)
			L["visibility"] = Convert(world.visibility)

		try
			if(dataSrc:type == /image)
				//create an image to access the appearance data
				//.["mode"] = "datum"
				var/image/I = new()
				I.appearance = dataSrc
				for(var/varname in I.vars)
					L[varname] = Convert(I.vars[varname])
				return .
		catch

		return


	proc/Convert(value)
		if(istext(value))
			return "\'[value]\'"
		if(isnum(value))
			return "[value]"
		if(isnull(value))
			return "null"
		if(ispath(value))
			return "[value]"
		if(isfile(value))
			return "[value]"

		. = list("disp" = "Error:Unsupported")
		if(istype(value,/list))
			.["disp"] = "/list([value:len])"
			.["ref"] = "\ref[value]"
			return
		if(istype(value,/client))
			.["disp"] = "/client([value:ckey])"
			.["ref"] = "\ref[value]"
			return
		if(istype(value,/datum))
			.["disp"] = "[value:type]"
			.["ref"] = "\ref[value]"
			return
		if(value == world)
			.["disp"] = "/world"
			.["ref"] = "\ref[value]"
			return
		else
			try
				if(value:type == /image)
					.["disp"] = "/appearance"
					.["ref"] = "\ref[value]"
			catch

		return .

	proc/Edit(varname)
		var/type = input(usr,"Select datatype:","VarEdit::[varname]",null) as null|anything in Controller.dataTypes
		var/value = null
		switch(type)
			if("null")
			if("default")
				value = initial(dataSrc:vars[varname])
			if("number")
				value = input(usr, "Input number:","VarEdit::[varname]",null) as null|num
			if("text")
				value = input(usr, "Input text:","VarEdit::[varname]",null) as null|text
			if("pointer")
			else
				return
		if(type != "null" && value == null)
			return

		if(isAppearance(dataSrc))
			var/image/I = new()
			I.appearance = dataSrc

			try
				I.vars[varname] = value
			catch
				DBG("Failed to set varname")
				return

			for(var/atom/A)
				if(A.appearance == dataSrc)
					A.appearance = I.appearance
					DBG("atom \ref[A]")

			for(var/image/J)
				if(J.appearance == dataSrc)
					J.appearance = I.appearance
					DBG("image \ref[J]")

			DBG("[dataSrc == I.appearance]")
			dataSrc = I.appearance

		else if(istype(dataSrc,/list))
			var/list/L = dataSrc
			var/i = round(text2num(varname))
			if(i < 1 || i > L.len)
				DBG("Index being editted is out of bounds")
				return
			L[i] = value
		else
			try
				dataSrc:vars[varname] = value
			catch
				DBG("Failed to set varname")
				return

		return 1

	proc/IsViewableInstance(instance)
		if(istext(instance) || isnum(instance) || isnull(instance) || ispath(instance))
			return 0
		if(istype(instance, /icon))
			return 1
		if(isfile(instance) || isicon(instance))
			return 0
		return 1


/atom/DblClick(location,control,params)
	new /variable_editor(src, usr)

