/datum/instancePool
	var/poolType = /datum
	var/list/pool

	New(poolSize=0, _poolType)
		if(ispath(_poolType))
			poolType = _poolType
		if(poolSize <= 0)
			pool = list()
		else
			pool = new /list(poolSize)
			for(var/i=1, i<=poolSize, ++i)
				pool[i] = new poolType()

	proc/Pop()
		var/datum/D = pop(pool)
		if(D)
			D.Init(arglist(args))
		else
			D = new poolType()
			D.Init(arglist(args))
		return D

	proc/Add(thing)
		if(istype(thing,poolType))
			pool.Add(thing)