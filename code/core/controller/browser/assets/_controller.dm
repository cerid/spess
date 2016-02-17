var/controller/asset/AssetCache

/controller/master/Init()
	AssetCache = new()
	return ..()

/controller/asset
	var/tellClientAmount = 1		//inform client that they are being sent assets (minbound)
	var/list/cache = list()		//"blahblah.png" = "path/to/file.png"

	New()
		var/list/L
		try
			L = JSON.Load(FILE_ASSET_TABLE)
		catch(var/e)
			logError(e)
		if(L)
			cache = L

	proc/Send(client/C, list/assetNames)
		if(!istype(C))
			if(ismob(C))
				var/mob/M = C
				if(M.client)
					C = M.client
				else
					return 0
			else
				return 0

		if(!istype(assetNames))
			assetNames = list(assetNames)

		var/data
		for(var/assetName in assetNames)
			data = cache[assetName]
			if(!data)
				logError("Asset([assetName]) not found in cache")

			else if(istext(data) && fexists(data))	//filePath
				C << browse_rsc(file(data), assetName)
				DBG("Sending [assetName]([data]) to client([C])...")
				if(tellClientAmount <= 1)
					OOC(C, "Downloaded Asset: [assetName]([data])")

			else if(istype(data, /list))
				Send(C, data)

