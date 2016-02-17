/proc/get_turf_step(turf/T, dir)
	var/x = T.x
	var/y = T.y
	if(dir & NORTH)
		++y
	else if(dir & SOUTH)
		--y
	if(dir & EAST)
		++x
	else if(dir & WEST)
		--x
	return locate(x, y, T.z)

/*
/turf/proc/Fill(rgb="#ff0000")
	color = rgb

/turf/proc/IsFilled(rgb="#ff0000")
	if(color == rgb)
		return 1


*/
/*
/proc/flash(turf/T)
	var/matrix/M = new()
	M.Scale(0.8)
	animate(T, transform=M,	5)
	animate(transform=null, 5)
	sleep(1)
*/


/proc/floodFill(turf/start, fillArg, fillCheck="CheckFlow", fill="MoveToArea")
	var/turf/cur,
	var/turf/nxt,
	var/dir = NORTH,
	var/markerDir,
	var/marker2Dir,
	var/findLoop = 0,
	var/backTrack = 0,
	var/turf/marker,
	var/turf/marker2,
	var/turf/markerBkp

	cur = start
	//flash(cur)
	nxt = get_turf_step(cur, dir)
	while(nxt && !call(nxt, fillCheck)(fillArg))
		cur = nxt
		nxt = get_turf_step(cur, dir)
		//flash(cur)

	while(1)
		var/count = 4
		for(var/i=0, i<4, ++i)
			nxt = get_turf_step(cur, turn(dir,90*i))
			if(nxt && !call(nxt, fillCheck)(fillArg))
				--count

		if(count < 4)
			do
				dir = turn(dir, -90)	//turn right
				nxt = get_turf_step(cur, dir)
			while(nxt && !call(nxt, fillCheck)(fillArg))
			do
				dir = turn(dir, 90)		//turn left
				nxt = get_turf_step(cur, dir)
			while(!nxt || call(nxt, fillCheck)(fillArg))

		switch(count)
			if(4)
				call(cur, fill)(fillArg)
				return
			if(3)
				marker = null
				call(cur, fill)(fillArg)
				cur = get_turf_step(cur, dir)
				//flash(cur)
				continue
			if(1)
				if(backTrack)
					findLoop = 1
				else if(findLoop)
					if(!marker)
						marker = markerBkp
				else
					nxt = get_turf_step(cur, turn(dir, 45))
					if(nxt && !call(nxt, fillCheck)(fillArg))
						nxt = get_turf_step(cur, turn(dir, -45))
						if(nxt && !call(nxt, fillCheck)(fillArg))
							markerBkp = marker
							marker = null
							call(cur, fill)(fillArg)
							cur = get_turf_step(cur, dir)
							//flash(cur)
							continue
			if(2)
				nxt = get_turf_step(cur, turn(dir, 180))
				if(!nxt || call(nxt, fillCheck)(fillArg))
					nxt = get_turf_step(cur, turn(dir, 45))
					if(nxt && !call(nxt, fillCheck)(fillArg))
						markerBkp = marker
						marker = null
						call(cur, fill)(fillArg)
						cur = get_turf_step(cur, dir)
						//flash(cur)
						continue
				else if(!marker)
					marker = cur
					markerDir = dir
					marker2 = null
					findLoop = 0
					backTrack = 0
				else if(!marker2)
					if(cur == marker)
						if(dir == markerDir)
							markerBkp = marker
							dir = turn(dir, 180)
							call(cur, fill)(fillArg)
							cur = get_turf_step(cur, dir)
							//flash(cur)
							continue
						else
							backTrack = 1
							findLoop = 0
							dir = markerDir
					else if(findLoop)
						marker2 = cur
						marker2Dir = dir
				else
					if(cur == marker)
						cur = marker2
						dir = marker2Dir
						markerBkp = marker
						marker = null
						marker2 = null
						backTrack = 0
						dir = turn(dir, 180)
						call(cur, fill)(fillArg)
						cur = get_turf_step(cur, dir)
						//flash(cur)
						continue
					else if(cur == marker2)
						marker = cur
						dir = marker2Dir
						markerDir = marker2Dir
						marker2 = null


		//
		cur = get_turf_step(cur, dir)
		//flash(cur)
		nxt = get_turf_step(cur, turn(dir, -90))
		if(nxt && !call(nxt, fillCheck)(fillArg))
			if(backTrack && !findLoop)
				nxt = get_turf_step(cur, dir)
				if(nxt && !call(nxt, fillCheck)(fillArg))
					findLoop = 1
				else
					nxt = get_turf_step(cur, turn(dir, 90))
					if(nxt && !call(nxt, fillCheck)(fillArg))
						findLoop = 1
			dir = turn(dir, -90)

			cur = get_turf_step(cur, dir)
			//flash(cur)


/proc/smoothwall(atom/Origin)
	var/dirs = 0
	var/turf/T
	if(isturf(Origin))
		for(var/d=1, d<=8, d<<=1)
			T = get_turf_step(Origin, d)
			if(istype(T, Origin.type))
				dirs |= d

	else if(isturf(Origin.loc))
		var/atom/A
		for(var/d=1, d<=8, d<<=1)
			T = get_turf_step(Origin.loc, d)
			if(!T)
				continue
			A = locate(Origin.type) in T
			if(A)
				dirs |= d

	var/id = 0
	var/r = 0
	switch(dirs)
		if(1)
			id = 1
		if(2)
			id = 1
			r = 180
		if(3)
			id = 3
		if(4)
			id = 1
			r = -90
		if(5)
			id = 5
		if(6)
			id = 5
			r = -90
		if(7)
			id = 7
		if(8)
			id = 1
			r = 90
		if(9)
			id = 5
			r = 90
		if(10)
			id = 5
			r = 180
		if(11)
			id = 7
			r = 180
		if(12)
			id = 3
			r = 90
		if(13)
			id = 7
			r = 90
		if(14)
			id = 7
			r = -90
		if(15)
			id = 15

	Origin.icon_state = initial(Origin.icon_state)
	if(id)
		Origin.icon_state += "_[id]"
		var/matrix/M = matrix()
		M.Turn(-r)
		Origin.transform = M