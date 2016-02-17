/datum/proc/Event(executeWhen=0, procName)
	ASSERT(hascall(src,procName))
	var/event/E = Controller.eventPool.Pop(src, executeWhen+world.time, procName)
	Controller.InsertEventInQueue(E)

/event
	parent_type = /datum
	var/executeWhen
	var/datum/executor
	var/procName

	Init(_executor, _executeWhen=0, _procName="Process")
		executeWhen = _executeWhen
		executor = _executor
		procName = _procName

	Del()
		//abort deletion, we are kept in a pool instead

	proc/Execute()
		call(executor,procName)()