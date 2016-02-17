var/controller/asset/AssetCache = new()

/controller/asset
	var/tellClientAmount = 1		//inform client that they are being sent assets (minbound)
	var/maxVerificationDelay = 3	//max number of ds we can wait for verification (maxbound)
	var/list/groups = list()	//assetGroup datums which can be sent to clients.
	var/list/cache = list()		//"blahblah.png" = "path/to/file.png"

	New()
		for(var/type in typesof(/assetGroup))
			new type()

	proc/Get(_type)
		var/assetGroup/A = groups[type]
		if(A)
			return A
		return new type()

	proc/SendGroup(client/C, groupType)
		var/assetGroup/A = Get(groupType)
		if(A)
			A.Send(C)

	proc/Register(assetName, assetPath)
		cache[assetName] = assetPath

	proc/Send(client/C, list/assetNames, verify=TRUE)
		if(!istype(C))
			if(ismob(C))
				var/mob/M = C
				if(M.client)
					C = M.client
				else
					return 0
			else
				return 0

		//convert assetName string into a list containing the string
		if(!istype(assetNames))
			assetNames = list(assetNames)

		//create list of assets that need to be sent
		var/list/pending = list()
		for(var/assetName in assetNames)
			if(!C.HasAsset(assetName))
				pending += assetName
		if(!pending.len)
			return 0

		//notify client if we are sending a lot of assets
		if(pending.len >= AssetCache.tellClientAmount)
			C << "Sending Resources..."

		//send each asset
		var/i = 0
		var/filePath
		for(var/assetName in assetNames)
			filePath = cache[assetName]
			if(!filePath)
				filePath = assetNames[assetName]
				if(!filePath)
					continue
				Register(assetName, filePath)
			C << browse_rsc(filePath, assetName)
			++i

		//
		if(!i)
			return 0

		if(!verify || !winexists(C, "asset_cache_browser"))
			if(C)
				C.assetsCache += pending
			return 1

		if(!C)
			return 0

		C.assetsSent += pending
		var/job = ++C.lastAssetJob

		//open asset_cache_browser which will call Topic to confirm transaction
		C << browse({"<script>window.location.href="?asset_cache_confirm_arrival=[job]"</script>"}, "window=asset_cache_browser")

		//blocking segment
		var/t = 0
		var/tMax = AssetCache.maxVerificationDelay * (C.assetsSent.len+1)
		while(C && !C.assetsCompletedJobs.Find(job) && t++ < tMax) // Reception is handled in Topic()
			sleep(1) // Lock up the caller until this is received.

		if(C)
			C.assetsSent -= pending
			C.assetsCache |= pending
			C.assetsCompletedJobs -= job

		return 1



/client
	var/list/assetsCompletedJobs = list()	//list to which completed jobs are added
	var/list/assetsCache = list()			//list to which recieved assets are added
	var/list/assetsSent = list()			//list to which assets pending confirmation of reciept are added
	var/lastAssetJob = 0

	proc/HasAsset(assetName)
		if(assetsCache.Find(assetName))
			return 2
		if(assetsSent.Find(assetName))
			return 1
		return 0

	New()
		spawn(-1)
			AssetCache.SendGroup(/assetGroup/essential)
		return ..()

	Topic(href, list/href_list, hsrc)
		if(href_list["asset_cache_confirm_arrival"])
			//src << "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED."
			var/job = text2num(href_list["asset_cache_confirm_arrival"])
			if(isnum(job))
				assetsCompletedJobs |= job
			return
		return ..()


/assetGroup
	var/list/assets = list()
	var/verify = FALSE

	New()
		if(assets && assets.len)
			AssetCache.groups[type] = src

	proc/Register()
		for(var/assetName in assets)
			AssetCache.Register(assetName, assets[assetName])

	proc/Send(client/C)
		Send(C, assets, verify)