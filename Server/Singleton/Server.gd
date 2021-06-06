extends Node

const port = 4444
var network = WebSocketServer.new()
# var network = NetworkedMultiplayerENet.new()
onready var root_node = get_tree().get_root()

func _ready():
	start_server()
	
func _process(_delta):
	if network.is_listening():
		network.poll()

func start_server():
	network.listen(port, PoolStringArray(), true);
	# network.create_server(port, 100)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(player_id):
	print("")

func _peer_disconnected(player_id):
	print("")

remote func CloseConnection():
	var player_id = get_tree().get_rpc_sender_id()
	network.disconnect_peer(player_id)

remote func addPlayer(uuid, username):
	var player_id = get_tree().get_rpc_sender_id()	
	Global.main[uuid] = username
	Global.mainAlt[username] = player_id

remote func removePlayer(uuid):
	Global.mainAlt.erase(Global.main[uuid])
	Global.main.erase(uuid)

# Lobby Function
remote func CreateRoom(roomName, leader):
	var player_id = get_tree().get_rpc_sender_id()
	if Global.room.has(roomName):
		rpc_id(player_id, "createResult", false, "Room name already exist!")
	else:
		Global.room[roomName] = [leader]
		rpc_id(player_id, "createResult", true, "Successfully created room!")

remote func JoinRoom(roomName, player):
	var player_id = get_tree().get_rpc_sender_id()
	if Global.room[roomName].size() >= 2:
		rpc_id(player_id, "joinResult", false)
	else:
		if Global.room[roomName].size() == 0:
			Global.room[roomName].push_front(player)
		else:
			Global.room[roomName].push_back(player)
			rpc_id(player_id, "joinResult", true)

remote func test():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "test_result", Global.main, Global.room, Global.mainAlt)

# Multiplayer
remote func getRooms():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "getRoomResult", Global.room)

# Room
remote func loadRoom(rmName, username):
	var playerId = get_tree().get_rpc_sender_id()
	var playerArr = Global.room[rmName]
	if playerArr.find(username) == 0: # User is leader
		rpc_id(playerId, "loadRoomResult", true, "")
	else: # User is not leader, return room leader 
		broadcastJoinRoom(rmName, username)
		rpc_id(playerId, "loadRoomResult", false, playerArr[0]) 

remote func readyBroadcast(rmName, userName, status):
	var playerArr = Global.room[rmName]
	var count = 0
	var message = ""
	if status:
		message = "Ready"
	else:
		message = "Not Ready"
	for player in playerArr:
		if player != userName:
			rpc_id(Global.mainAlt[player], "updateReady", message)
		++count

# Update the leader who has joined room
func broadcastJoinRoom(rmName, username):
	var playerArr = Global.room[rmName]
	var leader_id = Global.mainAlt[playerArr[0]]
	rpc_id(leader_id, "updateUserJoin", username)
