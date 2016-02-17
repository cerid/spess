//configuration datum reads JSON-like files (with some caveats)
/controller/config
	var/fps = FPS_DEFAULT
	var/peakUseCPU = CPU_DEFAULT
	//var/airSpreadRate = AIR_SPREAD_RATE_DEFAULT

	proc/Sanitize(list/data)
		var/errors = 0

		var/list/opts = AvailableOptions()

		var/currentValue
		var/newValue
		for(var/varName in data)
			if(!opts.Find(varName))
				++errors
				logError("Invalid config option: \"[varName]\"", FILE_CONFIG_ERROR)
				continue

			currentValue = opts[varName]
			newValue = data[varName]
			if(newValue == null)
				++errors
				logError("Null value attributed to: \"[varName]\"", FILE_CONFIG_ERROR)
				continue

			if(isnum(currentValue))
				if(!isnum(newValue))
					++errors
					logError("Non-numeric value attributed to: \"[varName]\"", FILE_CONFIG_ERROR)
					continue

			else if(istext(currentValue))
				if(!istext(newValue))
					++errors
					logError("Non-text value attributed to: \"[varName]\"", FILE_CONFIG_ERROR)
					continue

			else
				++errors
				logError("Default attribute type error for: \"[varName]\"", FILE_CONFIG_ERROR)

			vars[varName] = newValue


		//sanitize fps option
		if(fps >= FPS_MIN && fps <= FPS_MAX)
			var/temp = fps
			var/granuality = 1000

			if(gcd(granuality,temp) != fps)
				//doesn't divide to a whole number, meaning timings will be weird
				//Incrementally test surrounding numbers until we find a nice value
				var/a = fps
				var/b = fps
				while(--a >= FPS_MIN && ++b <= FPS_MAX)
					if(gcd(granuality,a) == fps)
						temp = a
						break
					if(gcd(granuality,b) == fps)
						temp = b
						break
			if(temp != fps)
				++errors
			fps = temp
		else
			fps = initial(fps)
			++errors

		return errors



	proc/Apply()
		world.fps = fps


	proc/AvailableOptions()
		. = list()
		for(var/varname in vars)
			if(varname == "tag")
				continue
			if(issaved(vars[varname]))
				.[varname] = vars[varname]

	New()
		var/needRewrite = 0

		var/list/data
		try
			data = JSON.Load(FILE_CONFIG)
		catch(var/exception/E)
			logError(E, FILE_CONFIG_ERROR)
			needRewrite = 1

		needRewrite += Sanitize(data)
		if(needRewrite)
			logError("Rewriting Config: \"[FILE_CONFIG]\"")
			try
				JSON.Save(AvailableOptions(), FILE_CONFIG)
			catch(var/e)
				logError(e)

/*
	proc/RestoreDefaults()
		for(var/varname in vars)
			vars[varname] = initial(vars[varname])
*/
