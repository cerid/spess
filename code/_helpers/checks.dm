/proc/hasVar(instance, varname)
	if(istype(instance,/datum) || istype(instance,/client))
		return instance:vars.Find(varname)
	return 0
