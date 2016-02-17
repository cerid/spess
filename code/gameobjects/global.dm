
/datum
	var/tmp/scheduled = 0

	proc/Process()
		scheduled &= ~SCHEDULED_PROCESS

	proc/ScheduleProcess(delay=0)
		if(scheduled & SCHEDULED_PROCESS)
			return
		scheduled |= SCHEDULED_PROCESS
		Event(delay, "Process")

	proc/Init()

/atom
	proc/UpdateAppearance()
		scheduled &= ~SCHEDULED_APPEARANCE

	proc/ScheduleUpdateAppearance()
		if(scheduled & SCHEDULED_APPEARANCE)
			return
		scheduled |= SCHEDULED_APPEARANCE
		Event(0, "UpdateAppearance")

mob
	step_size = STEP_SIZE_MOB
	icon = 'rsc/icon/mob.dmi'
	icon_state = "default"

obj
	step_size = STEP_SIZE_OBJ

