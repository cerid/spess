/datum/proc/UI(mob/viewer, uiID="main", ui/U, forceOpen=0, ui/parent, ui_state/state=Interface.stateDefault)
	return -1 // Sorta implemented.

/mob
	var/list/openUI = list()

/datum/proc/GetUIData(mob/viewer)
	return list()

/client/verb/uiclose(uiref as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = 1

	// Get the UI based on the ref.
	var/ui/U = locate(uiref)

	// If we found the UI, close it.
	if(istype(U) && U.user == usr)
		U.Close()
		// If there is a custom ref, call that atom's Topic().
/*
		if(U.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)
*/

