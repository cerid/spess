/client
	var/player/ID

	New()
		ID = Controller.GetPlayerID(ckey)
		return ..()