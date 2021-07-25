extends TextureRect

onready var highscoreValLbl = $highscoreValLabel
onready var worldOneBtn = $worldOneButton
onready var worldTwoBtn = $worldTwoButton
onready var worldThreeBtn = $worldThreeButton
onready var mapName = $mapNameLabel

var mapTracker = 0
var mapNames = ["Big Boxxy", "Castle", "Maze"]

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$usernameLabel.text = Global.username
	highscoreValLbl.bbcode_text = "[center][u]" + str(Global.highscore) + "[/u][/center]"
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_TextureRect_mouse_entered():
	$glowPanel.visible = true

func _on_TextureRect_mouse_exited():
	$glowPanel.visible = false

func _on_worldOneButton_pressed():
	BackgroundMusic.setMusicVolume(0)
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World1.tscn")

func _on_worldTwoButton_pressed():
	BackgroundMusic.setMusicVolume(0)
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World3.tscn")

func _on_worldThreeButton_pressed():
	BackgroundMusic.setMusicVolume(0)
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World2.tscn")

func _on_nextButton_pressed():
	mapTracker = mapTracker + 1
	if mapTracker > 2:
		mapTracker = 0
		
	if mapTracker == 0:
		worldOneBtn.visible = true
		worldTwoBtn.visible = false
		worldThreeBtn.visible = false
	elif mapTracker == 1:
		worldOneBtn.visible = false
		worldTwoBtn.visible = true
		worldThreeBtn.visible = false
	elif mapTracker == 2:
		worldOneBtn.visible = false
		worldTwoBtn.visible = false
		worldThreeBtn.visible = true
	mapName.text = mapNames[mapTracker]
		
func _on_prevButton_pressed():
	mapTracker = mapTracker - 1
	if mapTracker < 0:
		mapTracker = 2
		
	if mapTracker == 0:
		worldOneBtn.visible = true
		worldTwoBtn.visible = false
		worldThreeBtn.visible = false
	elif mapTracker == 1:
		worldOneBtn.visible = false
		worldTwoBtn.visible = true
		worldThreeBtn.visible = false
	elif mapTracker == 2:
		worldOneBtn.visible = false
		worldTwoBtn.visible = false
		worldThreeBtn.visible = true
	mapName.text = mapNames[mapTracker]

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ModeSelection.tscn")



