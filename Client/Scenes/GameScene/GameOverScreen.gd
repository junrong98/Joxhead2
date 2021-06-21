extends CanvasLayer

var player 
onready var coin_earned_value = $Coinearnedvalue

# Database related
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var invData = Global.gamedata

func _ready() -> void:
	for player_group_node in get_tree().get_nodes_in_group("Players"):
		player = player_group_node;
		break;

func _process(delta):
	coin_earned_value.text = str(player.coins_earned)
	
func updatePlayerCredit():
	invData["Credit"] = invData["Credit"] + int(coin_earned_value.text)
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})

func _on_ExitButton_pressed():
	get_tree().paused = false
	updatePlayerCredit()
	get_tree().call_group("DropLoot", "queue_free")
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	
func _on_RestartButton_pressed():
	Global.game_highscore = 0
	updatePlayerCredit()
	get_tree().paused = false
	get_tree().call_group("DropLoot", "queue_free")
	get_tree().reload_current_scene()
	
