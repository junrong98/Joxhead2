extends Node

const port = 4444
var network = WebSocketServer.new()
#var network = NetworkedMultiplayerENet.new()
onready var root_node = get_tree().get_root()
var rmname

func _ready():
	start_server()
	
func _process(_delta):
#	pass
	if network.is_listening():
		network.poll()

func start_server():
	network.listen(port, PoolStringArray(), true);
#	snetwork.create_server(port, 100)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(player_id):
	pass

func _peer_disconnected(player_id):
	if get_tree().get_root().has_node("(Multi)World"):
		get_tree().get_root().get_node("(Multi)World").delete_player(player_id)
		CloseConnectionDisconnected(player_id)
	else:
	# If user disconnected from server unexpectedly, we must remove them from
	# the respective dictionaries
		if Global.rpcAlt.has(player_id):
			var playerUUID = Global.rpcAlt[player_id]
			# Check if user is in any rooms
			for roomName in Global.room:
				var roomArr : Array = Global.room[roomName]
				if roomArr.has(playerUUID):
					if roomArr.find(playerUUID) == 0: # Player exiting is leader
						# It is false because the leader leaving is not through the UI
						deleteRoom(roomName, playerUUID, false)
					else: # If player existing is not leader
						removeUserFromRoom(roomName, playerUUID, false)
			Global.main.erase(playerUUID)
			Global.mainAlt.erase(playerUUID)

func CloseConnectionDisconnected(player_id):
	if Global.rpcAlt.has(player_id):
		var playerUUID = Global.rpcAlt[player_id]
		Global.main.erase(playerUUID)
		Global.mainAlt.erase(playerUUID)
	network.disconnect_peer(player_id)

remote func CloseConnection():
	var player_id = get_tree().get_rpc_sender_id()
	if Global.rpcAlt.has(player_id):
		var playerUUID = Global.rpcAlt[player_id]
		Global.main.erase(playerUUID)
		Global.mainAlt.erase(playerUUID)
	network.disconnect_peer(player_id)

remote func addPlayer(uuid, username):
	var player_id = get_tree().get_rpc_sender_id()
	# No other instance of user found online
	if !(Global.main.has(uuid)):
		Global.main[uuid] = username
		Global.mainAlt[uuid] = player_id
		Global.rpcAlt[player_id] = uuid
		rpc_id(player_id, "alreadyLoggedIn", false)
	else:
		rpc_id(player_id, "alreadyLoggedIn", true)

remote func removePlayer(uuid):
	Global.mainAlt.erase(Global.main[uuid])
	Global.main.erase(uuid)

# Lobby Function
remote func CreateRoom(roomName, leaderUUID):
	var player_id = get_tree().get_rpc_sender_id()
	if Global.room.has(roomName):
		rpc_id(player_id, "createResult", false, "Room name already exist!")
	else:
		Global.room[roomName] = [leaderUUID]
		rpc_id(player_id, "createResult", true, "Successfully created room!")

remote func JoinRoom(roomName, playerUUID):
	var player_id = get_tree().get_rpc_sender_id()
	# Check if room exist
	if Global.room.has(roomName):
		# If room is full
		if Global.room[roomName].size() >= 2:
			rpc_id(player_id, "joinResult", false, "Room is full")
		else:
			if Global.room[roomName].size() == 0:
				# This would not happen usually as player is the second player
				Global.room[roomName].push_front(playerUUID)
			else:
				Global.room[roomName].push_back(playerUUID)
				rpc_id(player_id, "joinResult", true, "")
	else:
		rpc_id(player_id, "joinResult", false, "Room does not exist. Please refresh.")

# Multiplayer
remote func getRooms():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "getRoomResult", Global.room)

# Room
remote func loadRoom(rmName, playerUUID):
	var playerId = get_tree().get_rpc_sender_id()
	var playerArr = Global.room[rmName]
	if playerArr.find(playerUUID) == 0: # User is leader
		rpc_id(playerId, "loadRoomResult", true, "")
	else:
		var leaderUUID = playerArr[0]
		var leaderUsername = Global.main[leaderUUID]
		# Update leader of who has joined the room
		broadcastJoinRoom(rmName, playerUUID)
		# User is not leader, return room leader username to player
		rpc_id(playerId, "loadRoomResult", false, leaderUsername) 

remote func readyBroadcast(rmName, userUUID, status):
	var playerArr = Global.room[rmName]
	var count = 0
	var message = ""
	if status:
		message = "Ready"
	else:
		message = "Not Ready"
	for playerUUID in playerArr:
		if playerUUID != userUUID:
			rpc_id(Global.mainAlt[playerUUID], "updateReady", message)
		++count

# Update the leader who has joined room
func broadcastJoinRoom(rmName, playerUUID):
	var playerArr = Global.room[rmName]
	# playerArr[0] is the leaderUUID
	# This is to get the rpc_id of the leader from mainAlt
	var leader_id = Global.mainAlt[playerArr[0]]
	# Get player username
	var playerUsername = Global.main[playerUUID]
	rpc_id(leader_id, "updateUserJoin", playerUsername)

# Delete room
remote func deleteRoom(roomName, leaderUUID, expected):
	var leader_id = get_tree().get_rpc_sender_id()
	var currRoom = Global.room[roomName]
	var otherPlayerUUID
	
	if currRoom.size() == 2:
		for playerUUID in currRoom:
			if playerUUID != leaderUUID:
				otherPlayerUUID = playerUUID
		# Get non-leader id
		var player_id = Global.mainAlt[otherPlayerUUID]
		# Update other player
		rpc_id(player_id, "leaveRoom")
	# Remove the room from the array
	Global.room.erase(roomName)
	# Update leader of successful deletion
	if expected: # The leader leaving the room is expected
		rpc_id(leader_id, "leaderLeaveRoom")
		
# Remove user from room
remote func removeUserFromRoom(roomName, playerUUID, expected):
	var playerId = get_tree().get_rpc_sender_id()
	Global.room[roomName].erase(playerUUID)
	var leaderUUID = Global.room[roomName][0]
	var leader_id = Global.mainAlt[leaderUUID]
	if expected:
		rpc_id(get_tree().get_rpc_sender_id(), "removeFromRoom")
	rpc_id(leader_id, "updatePlayerLeaveRoom")

remote func load_world(roomName):
	rpc("start_game")
	Global.activeRoom.push_back(roomName)
	var world = preload("res://Scenes/Multiplayer/(Multi)World.tscn").instance()
	get_tree().get_root().add_child(world)

remote func game_ended():
	if has_node("/root/(Multi)World"):	
		get_tree().get_root().get_node("(Multi)World").queue_free()

# Remove the room after game has ended
remote func clearRoom(roomName):
	var playerId = get_tree().get_rpc_sender_id()
	if Global.room.has(roomName):
		Global.room.erase(roomName)
	
	if Global.activeRoom.has(roomName):
		Global.activeRoom.erase(roomName)

remote func exit_midway(roomname):
	Global.room.erase(roomname)
	Global.activeRoom.erase(roomname)
