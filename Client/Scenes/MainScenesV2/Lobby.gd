extends TextureRect

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

onready var errLabel = $createContainer/errLabel
onready var rmNameInput = $createContainer/roomNameInput

func _ready():
	$usernameLabel.text = Global.username
	for room in Global.roomArr:
		var button = Button.new()
		var font = DynamicFont.new()
		font.font_data = load("res://Resources/Fonts/8bitlimr.ttf")
		font.size = 25
		button.text = room
		var customStyle = StyleBoxFlat.new()
		customStyle.bg_color = Color(128, 128, 128)
		customStyle.corner_radius_top_left = 3
		customStyle.corner_radius_top_right = 3
		customStyle.corner_radius_bottom_left = 3
		customStyle.corner_radius_bottom_right = 3
		button.set("custom_colors/font_color", Color(255, 0, 0))
		button.set("custom_fonts/font", font)
		button.set("custom_styles/normal", customStyle)
		button.set("custom_styles/hover", customStyle)
		button.connect("pressed", self, "button_press", [room])
		$lobbyContainer/lobbyScroll/roomContainer.add_child(button)
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

# Room Button function
func button_press(arr):
	Global.roomName = arr
	Server.joinRoom()

func _on_createRoomButton_pressed():
	if rmNameInput.text == "":
		errLabel.visible = true
		errLabel.text = "Please enter a room name"
	elif rmNameInput.text.length() > 8:
		errLabel.visible = true
		errLabel.text = "Room name is limited to 8 character"
	else:
		Global.roomName = rmNameInput.text
		Server.createRoom(rmNameInput.text, Global.uuid)

func _on_backButton_pressed():
	$lobbyContainer.visible = true
	$createContainer.visible = false

func _on_lobbyBackButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ModeSelection.tscn")

func _on_lobbyCreateRoomButton_pressed():
	$lobbyContainer.visible = false
	$createContainer.visible = true

func _on_refreshButton_pressed():
	$lobbyContainer/errLabel.visible = false
	Server.getRooms()
