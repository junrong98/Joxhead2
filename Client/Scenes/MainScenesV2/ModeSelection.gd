extends TextureRect

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$usernameLabel.text = Global.username
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_singlePlayerButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/SinglePlayerMode.tscn")

func _on_multiPlayerButton_pressed():
	Server.getRooms()

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")
