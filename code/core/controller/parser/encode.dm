	proc/WriteVarname()
	proc/WriteValue()
	proc/WriteList()
	proc/WriteType()
	proc/WriteBoolean()


	proc/WriteNull()
		return "null"


	proc/WriteString(string)
		return "\"[string]\""


	proc/WriteNumber(number)
		return "[number]"

