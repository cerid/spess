/client/Topic(href, list/href_list, datum/hsrc)
	//ui interaction
	if(istype(hsrc,/ui))
		DBG("[hsrc] Topic interaction: [url_decode(href)]")
		hsrc.Topic(href, href_list)
		return

	return	//disable all other topic calls being passed on