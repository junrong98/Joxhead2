extends CanvasLayer

var player 
var num_of_player
var possible_player
var curr_player_name
onready var coin_earned_value = $Panel2/Coinearnedvalue

# Database related
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var world = get_tree().get_root().get_node("World")
onready var invData = Global.gamedata
onready var multi_player = get_tree().get_root().find_node("Players", true, false)

func _ready() -> void:
	possible_player = multi_player.get_children()
	num_of_player = multi_player.get_child_count()


func _process(delta):
	coin_earned_value.text = str(Global.coin_earn)

func updatePlayerCredit():
	invData["Credit"] = invData["Credit"] + int(coin_earned_value.text)
	invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})

func check_highscore():
	if Global.game_highscore > Global.highscore:
		Global.highscore = Global.game_highscore
		Global.game_highscore = 0
		userCollection.update(Global.uuid, {"highscore" : Global.highscore})

func _on_ResumeButton_pressed():
	get_parent().remove_child(self)

func _on_ExitButton_pressed():
	check_highscore()
	updatePlayerCredit()
	BackgroundMusic.setMusicVolume(Global.currentBgVolume)
	get_parent().player_exited()
	Server.exitMiddle(Global.roomName)
	
