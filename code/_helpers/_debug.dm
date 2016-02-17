/proc/logError(exception/E, file)
	if(istext(file))
		file = file(file)
	else
		file = world.log

	if(istype(E))
		file << "\red\[[time2text(world.time,"hh:mm:ss")]\][E.file]:[E.line]:[E]"
		if(E.desc)
			file << "[E.desc]"
	else
		file << "\red\[[time2text(world.time,"hh:mm:ss")]\][E]"

world/Error(exception/E)
	logError(E)


