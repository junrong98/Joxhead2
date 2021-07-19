extends Node

# Dictionary: main = { uuid : username }
var main : Dictionary = {}
# Dictionary: mainAlt = { uuid : rpc_id }
var mainAlt : Dictionary = {}
# Dictionary: rpcAlt = { rpc_id : uuid }
var rpcAlt : Dictionary = {}
# Dictionary: room = { roomName : [uuid (leader), uuid (player)] }
var room : Dictionary = {}
# Dictionary: activeRoom = {}
var activeRoom : Array = []
	
