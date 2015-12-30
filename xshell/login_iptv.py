def Main():
	g_vWaitFors = [
		"Waiting for 1",
		"Waiting for 2",
		"Waiting for 3",
		"Waiting for 4",
		"Waiting for 5",
		"Waiting for 6",
		"Waiting for 7",
		"Waiting for 8",
		"Waiting for 9",
		"Waiting for 10"]

	msg=[]
	# recvMsgCnt=0
	
	msg.append("Password:")
	msg.append("is")
	
	xsh.Screen.Send("iptv")
	# recvMsgCnt = xsh.Screen.WaitForStrings("password", 1000)
	
	xsh.Screen.WaitForStrings(msg, 1000)
	# xsh.Screen.WaitForString("password")

	# xsh.Screen.WaitForStrings("aaa", 1000)		# input "aaa" in Terminal

	# if recvMsgCnt > 0:
		# xsh.Screen.Send('settopbox')

