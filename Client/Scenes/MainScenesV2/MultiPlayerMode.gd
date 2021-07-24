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
	highscoreValLbl = str(Global.highscore)
	Server.loadRoom(Global.roomName, Global.uuid)
	
	if Global.isLeader:
		$startButton.visible = true
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.maintainConnection()

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_TextureRect_mouse_entered():
	pass
	$glowPanel.visible = true

func _on_TextureRect_mouse_exited():
	pass
	$glowPanel.visible = false

func _on_worldOneButton_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World1.tscn")

func _on_worldTwoButton_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World2.tscn")

func _on_worldThreeButton_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/World3.tscn")

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

func _on_readyButton_pressed():
	$readyButton.visible = false
	$unreadyButton.visible = true
	Global.userReady = true
	if Global.isLeader:
		$leaderReadyLabel.text = "Ready"
	else:
		$playerReadyLabel.text = "Ready"
	Server.readyBroadcast(Global.userReady)

func _on_unreadyButton_pressed():
	$readyButton.visible = true
	$unreadyButton.visible = false
	Global.userReady = false
	if Global.isLeader:
		$leaderReadyLabel.text = "Not Ready"
	else:
		$playerReadyLabel.text = "Not Ready"
	Server.readyBroadcast(Global.userReady)

func _on_startButton_pressed():
	Global.game_highscore = 0
	if $leaderReadyLabel.text == "Ready" && $playerReadyLabel.text == "Ready":
		BackgroundMusic.setMusicVolume(0)
		Server.load_game()
	else:
		$errLabel.visible = true

func _on_backButton_pressed():
	if Global.isLeader:
		$cfmBackContainer.visible = true
	else:
		Server.userExitRoom(Global.roomName, Global.uuid)

func _on_noButton_pressed():
	$cfmBackContainer.visible = false

func _on_confirmButton_pressed():
	Global.isLeader = false
	Server.exitRoom(Global.roomName, Global.uuid)
	

