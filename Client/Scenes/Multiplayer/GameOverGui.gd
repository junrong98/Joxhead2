extends CanvasLayer

var player 
onready var coin_earned_value = $GameOverGui/Panel/richCoinEarnedValue

# Database related
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var invData = Global.gamedata


func _process(delta):
	coin_earned_value.text = str(Global.coin_earn)
	
func updatePlayerCredit():
	invData["Credit"] = invData["Credit"] + int(coin_earned_value.text)
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})

func _on_exitButton_pressed():
	get_tree().paused = false
	updatePlayerCredit()
	get_tree().call_group("DropLoot", "queue_free")
	BackgroundMusic.setMusicVolume(Global.currentBgVolume)
	Server.end_game()
