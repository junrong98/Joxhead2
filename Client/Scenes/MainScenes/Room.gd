extends Node2D

onready var userContainer = get_node("SinglePlayerLobby/playerContainer/userContainer")
onready var statusContainer = get_node("SinglePlayerLobby/playerContainer/statusContainer")
onready var statusOneContainer = get_node("SinglePlayerLobby/playerContainer/statusContainer/statusOne")
onready var statusTwoContainer = get_node("SinglePlayerLobby/playerContainer/statusContainer/statusTwo")

var userReady = false

func _ready():
	Server.loadRoom(Global.roomName, Global.username)

func _on_ReadyButton_pressed():
	if userReady:
		if Global.isLeader:
			statusOneContainer.text = "Not Ready"
		else:
			statusTwoContainer.text = "Not Ready"
		userReady = false
	else:
		if Global.isLeader:
			statusOneContainer.text = "Ready"
		else:
			statusTwoContainer.text = "Ready"
		userReady = true
	
	Server.readyBroadcast(userReady)
