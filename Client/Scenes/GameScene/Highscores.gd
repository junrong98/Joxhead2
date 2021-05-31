extends Label

# Display of highscores in the Game over menu. 
func _process(delta):
	text = str(Global.game_highscore)
