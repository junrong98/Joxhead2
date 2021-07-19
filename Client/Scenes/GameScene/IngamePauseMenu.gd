extends CanvasLayer

var player 
onready var coin_earned_value = $Panel/Coinearnedvalue

# Database related
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var world = get_tree().get_root().get_node("World")
onready var invData = Global.gamedata

func _ready() -> void:
	for player_group_node in get_tree().get_nodes_in_group("Players"):
		player = player_group_node;
		break;


func _process(delta):
	coin_earned_value.text = str(player.coins_earned)

func updatePlayerCredit():
	invData["Credit"] = invData["Credit"] + player.coins_earned
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})

func check_highscore():
	if Global.game_highscore > Global.highscore:
		Global.highscore = Global.game_highscore
		Global.game_highscore = 0
		userCollection.update(Global.uuid, {"highscore" : Global.highscore})


func _on_ResumeButton_pressed():
	get_tree().paused = false
	player.remove_child(self)


func _on_RestartButton_pressed():
	check_highscore()
	Global.game_highscore = 0
	updatePlayerCredit()
	get_tree().paused = false
	get_tree().call_group("DropLoot", "queue_free")
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	check_highscore()
	get_tree().paused = false
	updatePlayerCredit()
	get_tree().call_group("DropLoot", "queue_free")
	BackgroundMusic.setMusicVolume(Global.currentBgVolume)
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")
