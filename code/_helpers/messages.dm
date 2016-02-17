proc/OOC(viewer,message)
	viewer << output(message, OOC_CONTROL_ID)

proc/IC(viewer,message)
	viewer << output(message, IC_CONTROL_ID)