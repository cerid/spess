/turf
	var/blocksFlow = 0
	var/buildable = 0
	icon = 'rsc/icon/turf.dmi'
	icon_state = "turf"


/turf/wall
	density = 1
	blocksFlow = 1
	icon_state = "wall"

	New()
		..()
		ScheduleUpdateAppearance()

	UpdateAppearance()
		..()
		smoothwall(src)

/turf/floor

/turf/floor/room
	buildable = 1

/turf/door
	blocksFlow = 2
	icon_state = "door"
