extends TextureRect

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

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

func _on_controlButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ControlSetting.tscn")

func _on_soundButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/SoundSetting.tscn")

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Setting.tscn")
