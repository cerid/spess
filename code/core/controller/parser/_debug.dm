/client/verb/SpawnRoom(file as file)
	var/map_model/M = DMM.Load(file)
	ASSERT(M)
	var/turf/T = mob.loc
	M.Apply(T.x,T.y,T.z,UP)


