/ui_state/admin/CanInteract(dataSrc, mob/viewer)
	if(isAdmin(viewer))
		return UI_INTERACTIVE
	return UI_CLOSE // Don't allow interaction by default.

