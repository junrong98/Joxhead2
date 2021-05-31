extends CanvasLayer

func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainScenes/MainMenu.tscn")
	
func _on_RestartButton_pressed():
	Global.game_highscore = 0
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/GameScene/World.tscn")
