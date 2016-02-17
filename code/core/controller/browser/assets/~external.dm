/client
	New()
		spawn(0)	//delay sending of default assets briefly
			AssetCache.Send(src, ASSET_DEFAULT)
		return ..()