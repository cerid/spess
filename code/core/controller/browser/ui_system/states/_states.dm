/datum/proc/CanInteract(mob/viewer, ui_state/state)
	return state.CanInteract(src, viewer)

/ui_state/CanInteract(dataSrc, mob/viewer)
	return UI_CLOSE // Don't allow interaction by default.

