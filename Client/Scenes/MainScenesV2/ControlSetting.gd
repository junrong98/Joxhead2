extends TextureRect

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")
var controls = Global.settings["control"]

onready var upBtn = $VBoxContainer/ScrollContainer/VBoxContainer/upContainer/upButton
onready var dwnBtn = $VBoxContainer/ScrollContainer/VBoxContainer/downContainer/downButton
onready var leftBtn = $VBoxContainer/ScrollContainer/VBoxContainer/leftContainer/leftButton
onready var rightBtn = $VBoxContainer/ScrollContainer/VBoxContainer/rightContainer/rightButton
onready var minesBtn = $VBoxContainer/ScrollContainer/VBoxContainer/minesContainer/minesButton
onready var grenadeBtn = $VBoxContainer/ScrollContainer/VBoxContainer/grenadeContainer/grenadeButton
onready var barrelBtn = $VBoxContainer/ScrollContainer/VBoxContainer/barrelContainer/barrelButton
onready var wallsBtn = $VBoxContainer/ScrollContainer/VBoxContainer/wallsContainer/wallsButton
onready var nextWpnBtn = $VBoxContainer/ScrollContainer/VBoxContainer/nextWeapon/nextButton
onready var prevWpnBtn = $VBoxContainer/ScrollContainer/VBoxContainer/prevWeapon/prevButton

func _ready():
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")
	Server.maintainConnection()
	$usernameLabel.text = Global.username	
	ControlScript.setKeyDict(Global.settings["control"])
	upBtn.text = OS.get_scancode_string(controls["up_W"])
	dwnBtn.text = OS.get_scancode_string(controls["down_S"])
	leftBtn.text = OS.get_scancode_string(controls["left_A"])
	rightBtn.text = OS.get_scancode_string(controls["right_D"])
	minesBtn.text = OS.get_scancode_string(controls["plant_landmine"])
	grenadeBtn.text = OS.get_scancode_string(controls["throw_item"])
	barrelBtn.text = OS.get_scancode_string(controls["place_barrel"])
	wallsBtn.text = OS.get_scancode_string(controls["place_fakewall"])
	nextWpnBtn.text = OS.get_scancode_string(controls["next_weapon"])
	prevWpnBtn.text = OS.get_scancode_string(controls["previous_weapon"])

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/GameplaySetting.tscn")
