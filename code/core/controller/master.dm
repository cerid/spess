/controller/master
	var/mapLoaded = 0

	var/area/defaultArea

	var/list/queuedEvents = list()
	var/datum/instancePool/eventPool = new(0, /event)

	//var/list/subSystems = list()

	proc/OnMapLoad()
		mapLoaded = 1
		Config.Apply()

		Init()

		spawn(0)
			var/turf/T = locate(1,1,1)
			Controller.defaultArea = T.loc
			//CreateAirGroups()
			Process()

	Process()
		set background = 1
		while(1)
			var/event/E
			var/i=0
			for(var/thing in queuedEvents)
				if(world.cpu >= Config.peakUseCPU)
					break
				if(thing)
					E = thing
					if(E.executeWhen > world.time)
						break

					spawn(-1)
						Controller.eventPool.Add(E)
						E.Execute()
				++i

			if(i++)
				queuedEvents.Cut(1,i)

			sleep(world.tick_lag)

//event scheduling
	proc/InsertEventInQueue(event/E)
		queuedEvents += E
		sortInsert(queuedEvents, cmp=/proc/cmp_event, headStart=-1)	//this will assume the entire list is sorted, except for the last element


/client/Stat()
	if(!mob) return
	statpanel("DEBUG","CPU Load", world.cpu)
	statpanel("DEBUG","Time", world.time)
	statpanel("DEBUG","TickLag", world.tick_lag)
	..()

