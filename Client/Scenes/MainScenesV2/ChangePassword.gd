extends TextureRect
# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

onready var passwordInpt = $MarginContainer/VBoxContainer/VBoxContainer/passwordInpt
onready var cfmPasswordInpt = $MarginContainer/VBoxContainer/VBoxContainer2/cfmPasswordInpt
onready var errLabel = $MarginContainer/VBoxContainer/VBoxContainer2/errLabel

func _ready():
	$usernameLabel.text = Global.username
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/AccountSetting.tscn")

func _on_confirmBtn_pressed():
	if passwordInpt.text == "" or cfmPasswordInpt.text == "" or \
	   passwordInpt.text.empty() or cfmPasswordInpt.text.empty():
		errLabel.text = "Please enter a valid password"
		errLabel.add_color_override("font_color", Color(255, 0, 0))
	elif passwordInpt.text != cfmPasswordInpt.text:
		errLabel.text = "Passwords do not match"
		errLabel.add_color_override("font_color", Color(255, 0, 0))
	else:
		Firebase.Auth.change_user_password(passwordInpt.text)
		errLabel.text = "Password changed successfully"
		errLabel.add_color_override("font_color", Color(0, 255, 0))
