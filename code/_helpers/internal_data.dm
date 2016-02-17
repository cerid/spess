/proc/isAppearance(instance)
	if(!istype(instance,/datum))
		try
			if(instance:type == /image)
				return 1
		catch
	return 0
