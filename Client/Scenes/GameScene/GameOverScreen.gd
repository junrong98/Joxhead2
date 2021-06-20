extends CanvasLayer

onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var player = get_node("/root/World/Player")
onready var coin_earned_value = $Coinearnedvalue
onready var invData = Global.gamedata

func _process(delta):
	coin_earned_value.text = str(player.coins_earned)

func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	
	invData["Credit"] = invData["Credit"] + int(coin_earned_value.text)
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
	
func _on_RestartButton_pressed():
	Global.game_highscore = 0
	get_tree().paused = false
	get_tree().call_group("DropLoot", "queue_free")
	#get_tree().change_scene("res://Scenes/GameScene/World.tscn")
	get_tree().reload_current_scene()
	
	invData["Credit"] = invData["Credit"] + int(coin_earned_value.text)
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
	
