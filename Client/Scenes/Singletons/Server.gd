extends Node

const IP_ADDRESS = "joxheadtest.herokuapp.com"
const PORT = 443
#const PORT = 4444
var server_url = 'wss://%s:%d/ws/' % [IP_ADDRESS, PORT]
var network = WebSocketClient.new()
#var network = NetworkedMultiplayerENet.new()

func _ready():
	pass

func _process(_delta):
	if network.get_connection_status() in [NetworkedMultiplayerPeer.CONNECTION_CONNECTED, NetworkedMultiplayerPeer.CONNECTION_CONNECTING]:
		network.poll()

func connect_to_server():
	network.connect_to_url(server_url, PoolStringArray(), true);
	# network.create_client("127.0.0.1", PORT)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
func _on_connection_failed():
	print("You have disconnected from the server")

func _on_connection_succeeded():
	rpc_id(1, "addPlayer", Global.uuid, Global.username)
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")

func logout():
	Firebase.Auth.logout()
	rpc_id(1, "CloseConnection")
	get_tree().change_scene("res://Scenes/MainScenes/Login.tscn")

func test():
	rpc_id(1, "test")

remote func test_result(main, room, mainAlt):
	print("User in lobby: " + str(main))
	print("Rooms " + str(room))
	print(mainAlt)
	
# Multiplayer
func getRooms():
	rpc_id(1, "getRooms")
	
func joinRoom():
	rpc_id(1, "JoinRoom", Global.roomName, Global.username)

func createRoom(roomName, leader):
	rpc_id(1, "CreateRoom", roomName, leader)
	
remote func getRoomResult(rooms):
	var roomArr = rooms.keys()
	Global.roomArr = roomArr
	Global.isLeader = true
	get_tree().change_scene("res://Scenes/MainScenes/Multiplayer.tscn")

remote func createResult(result, roomMsg):
	if result:
		get_node("/root/MultiplayerNode/CreateContainer/errLabel").text = roomMsg
		get_tree().change_scene("res://Scenes/MainScenes/Room.tscn")
		Global.isLeader = true
	else:
		get_node("/root/MultiplayerNode/CreateContainer/errLabel").text = roomMsg
		Global.roomName = ""
		
remote func joinResult(rslt):
	if rslt:
		get_tree().change_scene("res://Scenes/MainScenes/Room.tscn")		

# Room
func loadRoom(rmName, username):
	rpc_id(1, "loadRoom", rmName, username)

# Load room data when user reach the room scene.
remote func loadRoomResult(isLeader, otherPlayer):
	if isLeader:
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userOne").text = Global.username
	else:
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userOne").text = otherPlayer
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userTwo").text = Global.username
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userTwo").visible = true
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/statusContainer/statusTwo").visible = true
		
# Broadcast an update to player in the room.
func readyBroadcast(ready):
	rpc_id(1, "readyBroadcast", Global.roomName, Global.username, ready)

# Broadcast ready/unready
remote func updateReady(message):
	if Global.isLeader:
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/statusContainer/statusTwo").text = message
	else:
		get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/statusContainer/statusOne").text = message
		
# User join room (only used if player is leader)
remote func updateUserJoin(username):
	get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userTwo").text = username
	get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/userContainer/userTwo").visible = true
	get_node("/root/RoomContainer/SinglePlayerLobby/playerContainer/statusContainer/statusTwo").visible = true
