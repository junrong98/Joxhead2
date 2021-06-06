extends Node2D

onready var lobbyContainer = get_node("LobbyContainer")
onready var lobbyScroll = get_node("LobbyContainer/LobbyScroll/RoomContainer")

# Create Container
onready var createContainer = get_node("CreateContainer")
onready var rmNameInput = get_node("CreateContainer/rmNameInput")
onready var errLabel = get_node("CreateContainer/errLabel")

func _ready():
	for room in Global.roomArr:
		var button = Button.new()
		var font = DynamicFont.new()
		font.font_data = load("res://Resources/Fonts/BleedingPixels.ttf")
		font.size = 30
		button.text = room
		button.connect("pressed", self, "button_press", [room])
		button.set("custom_fonts/font", font)
		lobbyScroll.add_child(button)

# Room Button function
func button_press(arr):
	Global.roomName = arr
	Server.joinRoom()

func _on_CreateRoomBtn_pressed():
	lobbyContainer.visible = false
	createContainer.visible = true

func _on_CreateRoom2Btn_pressed():
	if rmNameInput.text == "":
		errLabel.text = "Please enter a room name"
	elif rmNameInput.text.length() > 8:
		errLabel.text = "Room name is limited to 8 character"
	else:
		Global.roomName = rmNameInput.text
		Server.createRoom(rmNameInput.text, Global.username)
		
