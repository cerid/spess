/controller/master
	var/list/playerIDs = list()

	proc/GetPlayerID(ckey)
		var/player/ID = playerIDs[ckey]
		if(!ID)
			ID = new(ckey)
		return ID

/player
	var/ckey
	var/rights = 1

	New(_ckey)
		ckey = _ckey
		Controller.playerIDs[ckey] = src

proc/isAdmin(who)
	var/player/P = who
	if(!istype(P))
		if(istext(who))
			P = Controller.GetPlayerID(ckey(who))
		else
			if(istype(who, /mob))
				who = who:client
			if(istype(who, /client))
				P = who:ID
			else
				return 0

	return P.rights