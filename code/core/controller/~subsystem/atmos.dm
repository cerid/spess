/area
	alpha = 0
	icon = 'rsc/icon/area.dmi'
	icon_state = "default"
	layer = FLY_LAYER
	mouse_opacity = 0

	//var/breaches = 0
	var/list/Neighbours = list()

	var/pressure = AIR_PRESSURE_NOMINAL
	var/groupSize = 0

	//percentage values (0->100) vvv
	var/oxygen = 21
	var/nitrogen = 78
	var/carbon = 1
	var/toxin = 0
	var/radiation = 0

/*
	verb/test()
		set src in world
		pressure = input(usr) as num
		ScheduleUpdateAppearance()
		//world << "\ref[src] water=[water]; breaches=[breaches]; alpha=[alpha]"

	UpdateAppearance()
		..()
		var/t = min(max(0,(pressure/AIR_PRESSURE_CAP)+1),1)
		var/base = min(max(0,255*t),255)
		var/r = base
		var/g = base
		var/b = base
		var/a = (1-t) * 100

		var/rgba = rgb(min(max(0,r),255), min(max(0,g),255), min(max(0,b),255), min(max(0,a),255))
		animate(src, color=rgba, ANIMATE_LENGTH)

	Process()
		..()
		ScheduleUpdateAppearance()
*/

/*
	proc/Rebuild()
		var/turf/T = locate() in contents
		if(!T)
			return

		var/area/A
		if(groupSize > 1)
			A = new()
			A.pressure = pressure * groupSize
		else
			A = src

		floodFill(T, A, "CheckFlow", "MoveToArea")

		A.pressure /= A.groupSize
		A.ScheduleUpdateAppearance()
*/
/*
/datum/master_controller/proc/DestroyAirGroups()
	var/turf/T = locate(1,1,1)
	var/area/A = T.loc

	for(T in world)
		T.MoveToArea(A)
*/
/*
/datum/master_controller/proc/CreateAirGroups()
	var/turf/T = locate(1,1,1)
	var/area/A = T.loc

	for(T in world)
		if(T.loc != A)
			continue
		if(T.BlocksFlow())
			continue
		T.CreateAirGroup()

	T = locate(1,1,1)
	A = T.loc
	A.pressure = -100
	A.ScheduleUpdateAppearance()
*/


/turf

	New()
		..()
		ScheduleProcess()

	Process()
		..()
		if(blocksFlow)
			return 2
		if(loc != Controller.defaultArea)
			return 1
		CreateAirGroup()

	proc/MoveToArea(area/A)
		if(loc == A)
			return 1
		if(loc)
			var/area/B = loc
			B.groupSize = max(0, B.groupSize-1)
		A.contents.Add(src)
		++A.groupSize
		return 0

	proc/CheckFlow(area/A)
		if(blocksFlow)
			return 2
		if(loc == A)
			return 1
		return 0

	proc/CreateAirGroup(area/A)
		if(!A)
			A = new()
		floodFill(src, A)
		return A
/*
	DblClick()
		world << "\ref[src] : \ref[src.loc]"
//		loc:test()
*/