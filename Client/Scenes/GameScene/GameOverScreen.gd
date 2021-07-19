extends CanvasLayer

var player 
onready var coin_earned_value : RichTextLabel = $Panel/richCoinEarnedValue

# Database related
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var invData = Global.gamedata

func _ready() -> void:
	for player_group_node in get_tree().get_nodes_in_group("Players"):
		player = player_group_node;
		break;


func _process(delta):
	var start_coin = 0
	while start_coin < player.coins_earned:
		coin_earned_value.bbcode_text = "[center][u]" + str(player.coins_earned) + "[/u][/center]"
		yield(get_tree().create_timer(0.01),"timeout")
		start_coin = start_coin + 1

func updateScore():
	if Global.game_highscore > Global.highscore:
		Global.highscore = Global.game_highscore
		Global.game_highscore = 0
		userCollection.update(Global.uuid, {"highscore" : Global.highscore})

func updatePlayerCredit():
	invData["Credit"] = invData["Credit"] + player.coins_earned
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})

func _on_restartButton_pressed():
	Global.game_highscore = 0
	updatePlayerCredit()
	updateScore()
	get_tree().paused = false
	get_tree().call_group("DropLoot", "queue_free")
	get_tree().reload_current_scene()

func _on_exitButton_pressed():
	get_tree().paused = false
	updatePlayerCredit()
	updateScore()
	get_tree().call_group("DropLoot", "queue_free")
	BackgroundMusic.setMusicVolume(Global.currentBgVolume)
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")
