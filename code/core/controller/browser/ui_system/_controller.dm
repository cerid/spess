var/controller/ui/Interface

/controller/master/Init()
	Interface = new()
	return ..()


/controller/ui
	var/refreshRate = 10	//1 second

	var/ui_state/stateDefault = new()
	var/ui_state/admin/stateAdmin = new()

	var/baseHTML = ""
	var/list/openUI = list()
	var/list/processingUI = list()

	New()
		baseHTML = file2text(FILE_DEFAULT_HTML)
		ScheduleProcess(refreshRate)

	Process()
		//set waitfor = 0 // Don't wait on sleep()s.
		for(var/datum in processingUI)
			if(datum)
				datum:Process()
		. = ..()
		ScheduleProcess(refreshRate)

	proc/OnOpen(ui/U)
		var/key = "\ref[U.dataSrc]"
		if(!istype(openUI[key],/list))
			openUI[key] = list(U.uiID = list())
		else
			var/list/L = openUI[key]
			if(!istype(L[U.uiID],/list))
				L[U.uiID] = list()

		//append the UI to all the lists
		U.user.openUI |= U
		openUI[key][U.uiID] |= U
		processingUI |= U

	proc/OnClose(ui/U)
		var/key = "\ref[U.dataSrc]"
		if(!istype(openUI[key],/list))
			return 0 // It wasn't open.
		else if(!istype(openUI[key][U.uiID],/list))
			return 0 // It wasn't open.

		processingUI.Remove(U) // Remove it from the list of processing UIs.
		if(U.user)	// If the user exists, remove it from them too.
			U.user.openUI.Remove(U)
		openUI[key][U.uiID] -= U // Remove it from the list of open UIs.
		return 1 // Let the caller know we did it.


	proc/TryUpdate(mob/user, datum/dataSrc, uiID, ui/U, list/data, forceOpen=0)
		if(!data)
			data = dataSrc.GetUIData(user)

		if(!U) // No UI was passed, so look for one.
			U = GetOpenUI(user, dataSrc, uiID)

		if(U)
			if(!forceOpen) // UI is already open; update it.
				U.PushData(data)
			else // Re-open it anyways.
				U.Reinitialize(null, data)
			return U // We found the UI, return it.
		else
			return null // We couldn't find a UI.

	proc/GetOpenUI(mob/user, datum/dataSrc, uiID)
		var/key = "\ref[dataSrc]"
		if(!istype(openUI[key], /list))
			return null // No UIs open.
		else if(!istype(openUI[key][uiID], /list))
			return null // No UIs open for this object.

		var/list/L = openUI[key][uiID]
		for(var/ui/U in L) // Find UIs for this object.
			if(U.user == user) // Make sure we have the right user
				return U

		return null // Couldn't find a UI!

	proc/UpdateObjectUI(dataSrc)
		var/key = "\ref[dataSrc]"
		if(!istype(openUI[key], /list))
			return 0 // Couldn't find any UIs for this object.

		var/updateCount = 0
		for(var/uiID in openUI[key])
			for(var/ui/U in openUI[key][uiID])
				if(U && U.dataSrc && U.user) // Check the UI is valid.
					U.Process(force=1) // Update the UI.
					++updateCount // Count each UI we update.
		return updateCount
