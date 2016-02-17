/ui
	var/mob/user	//Client using this ui
	var/datum/dataSrc	//source object of data for this ui

	var/title	//title of the ui
	var/uiID	//identifier for this ui, this allows multiple ui per data object
	var/windowID	//id used by browse() to target the correct browser window on the client's screen
	var/width = 0	//width of window
	var/height = 0	//height of window

	var/list/windowOptions = list( // Extra options to browse().
	  "focus" = 0,
	  "titlebar" = 0,
	  "can_resize" = 0,
	  "can_minimize" = 0,
	  "can_maximize" = 0,
	  "can_close" = 0,
	  "auto_format" = 0
	)
	var/style = "default"	// The style to be used for this UI.
	var/interface			// The interface (template) to be used for this UI.
	var/autoUpdate = 0		// Automatically update this UI regularly
	var/initialized = 0
	var/list/initialData	// The data (and datastructure) used to initialize the UI.

	var/status = UI_INTERACTIVE		// The status/visibility of the UI.
	var/ui_state/state		// Topic state used to determine status/interactability.
	var/ui/parent					// The parent UI.
	var/list/ui/children			// Children of this UI.


	New(mob/_user, datum/_dataSrc, _uiID, _interface, _title, _width=0, _height=0, ui/_parent, ui_state/_state = Interface.stateDefault)
		user = _user
		dataSrc = _dataSrc
		uiID = _uiID
		windowID = "\ref[dataSrc]-[uiID]"

		SetInterface(_interface)

		if(_title)
			title = Sanitize(_title)
		if(_width > 0)
			width = _width
		if(_height > 0)
			height = _height

		parent = _parent
		if(parent)
			if(!parent.children)
				parent.children = new()
			parent.children.Add(src)
		state = _state


	proc/Open()
		set waitfor = 0 // Don't wait on sleep()s.
		if(!user || !user.client || !dataSrc)
			return // Bail if there is no client or dataSrc

		UpdateStatus(push = 0) // Update the window status.
		if(status == UI_CLOSE)
			return // Bail if we're not supposed to open.

		if(!initialData)
			SetInitialData(dataSrc.GetUIData(user)) // Get the UI data.

		var/winSize = ""
		if(width && height) // If we have a width and height, use them.
			winSize = "size=[width]x[height];"

		var/debuggable = 1
		user << browse(GetHTML(debuggable), "window=[windowID];[winSize][list2params(windowOptions)]") // Open the window.
		winset(user, windowID, "on-close=\"uiclose \ref[src]\"") // Instruct the client to signal UI when the window is closed.
		Interface.OnOpen(src)


	proc/Reinitialize(_interface, list/_data)
		if(_interface)
			SetInterface(_interface) // Set a new interface.
		if(_data)
			SetInitialData(_data) // Replace the initial_data.
		Open()


	proc/Close()
		user << browse(null, "window=[windowID]") // Close the window.
		Interface.OnClose(src)
		if(children)
			for(var/ui/child in children) // Loop through and close all children.
				child.Close()
			children = null
		state = null
		parent = null

/*
	proc/SetWindowOptions(list/L)
		if(L)
			windowOptions = L
*/
/*
	proc/SetStyle(_style)
		style = lowertext(_style)
*/

	proc/SetInterface(_interface)
		interface = lowertext(_interface)

/*
	proc/SetAutoUpdate(state=1)
		autoUpdate = state
*/

	proc/SetInitialData(list/data)
		initialData = data ? data : list()


	proc/GetHTML(inline=0)
		var/html = Interface.baseHTML
		if(inline)
			html = replaceTextOnceEx(html, "{}", GetJSON(initialData))
		html = replaceTextOnceEx(html, "\[ref\]", "\ref[src]")
		html = replaceTextOnceEx(html, "\[style\]", style)
		return html


	proc/GetConfigData()
		. = list(
			"title"      = title,
			"status"     = status,
			"style"      = style,
			"interface"  = interface,
			"fancy"      = 1,
			"window"     = windowID,
			"ref"        = "\ref[src]",
			"user"       = list("name" = user.name, "ref"  = "\ref[user]"),
			"srcObject"  = list("name" = istype(dataSrc,/atom) ? dataSrc:name : "[dataSrc.type]", "ref"  = "\ref[dataSrc]")
			)
		return .


	proc/GetJSON(list/data)
		var/list/L = list("config"=GetConfigData())
		if(istype(data))
			L["data"] = data

		// Generate the JSON; replace bad characters.
		var/encoded = JSON.Encode(L, 1)
		encoded = replaceTextEx(encoded, "\improper", "")
		encoded = replaceTextEx(encoded, "\proper", "")
		//DBG("encoded = [encoded]")
		return encoded


	Topic(href, href_list)
		if(user != usr)
			return	//prevent people interacting with other peoples uis

		var/action = href_list["action"]
		switch(action)
			if("tgui:initialize")
				user << output(url_encode(GetJSON(initialData)), "[windowID].browser:initialize")
				initialized = TRUE
				return

		UpdateStatus(push=0) // Update the window state.
		if(status != UI_INTERACTIVE)
			return // If UI is not interactive.

		var/update = dataSrc.Topic(href, href_list, state) // Call ui_act() on the src_object.
		if(dataSrc && update)
			Interface.UpdateObjectUI(dataSrc) // If we have a src_object and its ui_act() told us to update.


	Process(force=0)
		if(!dataSrc || !user) // If the object or user died (or something else), abort.
			Close()
			return

		if(status && (force || autoUpdate))
			Update() // Update the UI if the status and update settings allow it.
		else
			UpdateStatus(1) // Otherwise only update status.


	proc/PushData(list/data, force=0)
		DBG("PUSH")
		UpdateStatus(push=0) // Update the window state.
		if(status<=UI_DISABLED && !force)
			return // Cannot update UI, we have no visibility.

		// Send the new JSON to the recieveUpdate() Javascript function.
		user << output(url_encode(GetJSON(data)), "[windowID].browser:update")


	proc/Update(forceOpen=0)
		dataSrc.UI(user, uiID, src, forceOpen, parent, state)


	proc/UpdateStatus(push=0)
		var/status = UI_CLOSE	//default to close in case there is no longer a dataSrc
		if(dataSrc)
			status = dataSrc.CanInteract(user, state)
		if(parent)
			status = min(status, parent.status)

		SetStatus(status, push)
		if(status == UI_CLOSE)
			Close()


	proc/SetStatus(_status, push=0)
		if(status != _status) // Only update if status has changed.
			if(status == UI_DISABLED)
				status = _status
				if(push)
					Update()
			else
				status = _status
				if(status == UI_DISABLED || push) // Update if the UI just because disabled, or a push is requested.
					PushData(null, force=1)


	proc/Sanitize(text)
		return html_encode(text)






