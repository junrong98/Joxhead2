extends CanvasLayer

onready var player = get_node("/root/World/Player")
onready var coin_earned_value = $Coinearnedvalue

func _process(delta):
	coin_earned_value.text = str(player.coins_earned)

func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	
func _on_RestartButton_pressed():
	Global.game_highscore = 0
	get_tree().paused = false
	get_tree().call_group("DropLoot", "queue_free")
	#get_tree().change_scene("res://Scenes/GameScene/World.tscn")
	get_tree().reload_current_scene()
	
