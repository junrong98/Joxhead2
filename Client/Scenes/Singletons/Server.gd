extends Node

const IP_ADDRESS = "joxhead.herokuapp.com"
const PORT = 443
#const PORT = 4444
var server_url = 'wss://%s:%d/ws/' % [IP_ADDRESS, PORT]
var network = WebSocketClient.new()
#var network = NetworkedMultiplayerENet.new()

func _ready():
	pass

func _process(_delta):
#	pass
	if network.get_connection_status() in [NetworkedMultiplayerPeer.CONNECTION_CONNECTED, NetworkedMultiplayerPeer.CONNECTION_CONNECTING]:
			network.poll()

func connect_to_server():
	network.connect_to_url(server_url, PoolStringArray(), true);
#	network.create_client("127.0.0.1", PORT)
	get_tree().set_network_peer(network)
	if !network.is_connected("connection_failed", self, "_on_connection_failed"):
		network.connect("connection_failed", self, "_on_connection_failed")
	if !network.is_connected("connection_succeeded", self, "_on_connection_succeeded"):
		network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
func _on_connection_failed():
	print("You have disconnected from the server")

func _on_connection_succeeded():
	rpc_id(1, "addPlayer", Global.uuid, Global.username)
	
remote func alreadyLoggedIn(isLoggedIn):
	if isLoggedIn:
		rpc_id(1, "CloseConnection")
		# Needed such that user can login again after logging out
		network = WebSocketClient.new()
		# network = NetworkedMultiplayerENet.new()
		get_node("/root/Background/loginForm/loginErrLbl").text = "You are already logged in."
		get_node("/root/Background/loginForm/loginErrLbl").add_color_override("font_color", Color(1, 0, 0))
		get_node("/root/Background/loadingPanel").visible = false
		get_node("/root/Background/loadingAnimationG1").stop()
		get_node("/root/Background/loadingAnimationG2").stop()
		get_node("/root/Background/loadingAnimationG3").stop()
		get_node("/root/Background/loadingGrenade1").visible = false
		get_node("/root/Background/loadingGrenade2").visible = false
		get_node("/root/Background/loadingGrenade3").visible = false
	else:
		get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")

func logout():
	Firebase.Auth.logout()
	rpc_id(1, "CloseConnection")
	# Needed such that user can login again after logging out
	network = WebSocketClient.new()
#	network = NetworkedMultiplayerENet.new()
	get_tree().change_scene("res://Scenes/MainScenesV2/Login.tscn")

# Multiplayer
func getRooms():
	rpc_id(1, "getRooms")
	
func joinRoom():
	rpc_id(1, "JoinRoom", Global.roomName, Global.uuid)

func createRoom(roomName, leader):
	rpc_id(1, "CreateRoom", roomName, leader)
	
remote func getRoomResult(rooms):
	var roomArr = rooms.keys()
	Global.roomArr = roomArr
	get_tree().change_scene("res://Scenes/MainScenesV2/Lobby.tscn")

remote func createResult(result, roomMsg):
	if result:
		get_tree().change_scene("res://Scenes/MainScenesV2/MultiPlayerMode.tscn")
		Global.isLeader = true
	else:
		get_node("/root/Background/createContainer/errLabel").text = roomMsg
		Global.roomName = ""
		
remote func joinResult(rslt, errMessage):
	if rslt:
		get_tree().change_scene("res://Scenes/MainScenesV2/MultiPlayerMode.tscn")
	else:
		get_node("/root/Background/lobbyContainer/errLabel").visible = true
		get_node("/root/Background/lobbyContainer/errLabel").text = errMessage

# Room
func loadRoom(rmName, playerUUID):
	rpc_id(1, "loadRoom", rmName, playerUUID)

# Load room data when user reach the room scene.
remote func loadRoomResult(isLeader, otherPlayer):
	if isLeader:
		get_node("/root/roomContainer/leaderLabel").text = Global.username
		get_node("/root/roomContainer/leaderLabel").visible = true
		get_node("/root/roomContainer/leaderReadyLabel").visible = true
	else:
		get_node("/root/roomContainer/leaderLabel").visible = true
		get_node("/root/roomContainer/leaderReadyLabel").visible = true
		get_node("/root/roomContainer/leaderLabel").text = otherPlayer
		get_node("/root/roomContainer/playerLabel").text = Global.username
		get_node("/root/roomContainer/playerLabel").visible = true
		get_node("/root/roomContainer/playerReadyLabel").visible = true
		
# Broadcast an update to player in the room.
func readyBroadcast(ready):
	rpc_id(1, "readyBroadcast", Global.roomName, Global.uuid, ready)

# Broadcast ready/unready
remote func updateReady(message):
	if Global.isLeader:
		get_node("/root/roomContainer/playerReadyLabel").text = message
	else:
		get_node("/root/roomContainer/leaderReadyLabel").text = message
		
# User join room (only used if player is leader)
remote func updateUserJoin(username):
	get_node("/root/roomContainer/playerLabel").text = username
	get_node("/root/roomContainer/playerLabel").visible = true
	get_node("/root/roomContainer/playerReadyLabel").visible = true
	
func exitRoom(roomName, leaderUUID):
	# True as this is expected as the leader chose to leave the room
	rpc_id(1, "deleteRoom", roomName, leaderUUID, true)
	
remote func leaveRoom():
	get_node("/root/roomContainer/leaveRoomContainer").visible = true
	yield(get_tree().create_timer(3),"timeout")
	getRooms()

remote func leaderLeaveRoom():
	getRooms()

func userExitRoom(roomName, playerUUID):
	rpc_id(1, "removeUserFromRoom", roomName, playerUUID, true)

remote func removeFromRoom():
	get_tree().change_scene("res://Scenes/MainScenesV2/Lobby.tscn")
	
remote func updatePlayerLeaveRoom():
	get_node("/root/roomContainer/playerLabel").text = ""
	get_node("/root/roomContainer/playerLabel").visible = false
	get_node("/root/roomContainer/playerReadyLabel").visible = false
	get_node("/root/roomContainer/leaderReadyLabel").text = "Not Ready"
	Global.userReady = false
	Global.otherReady = false

# Multiplayer
func load_game():
	Global.game_highscore = 0
	rpc_id(1, "load_world", Global.roomName)

func exitMiddle(roomname):
	Global.roomName = ""
	rpc_id(1, "exit_midway", roomname)
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")

sync func start_game():
	var world = preload("res://Scenes/Multiplayer/(Multi)World.tscn").instance()
	get_tree().change_scene("res://Scenes/Multiplayer/(Multi)World.tscn")

func end_game():
	rpc_id(1, "game_ended")
	var world = get_node("/root/(Multi)World")
	clearRoom()
	if has_node("/root/(Multi)World"):
		world.queue_free()
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")

# After game has ended, which ever user click on `Exit` first will clear the room
# on the server. Does not matter who does it first
func clearRoom():
	rpc_id(1, "clearRoom", Global.roomName)

