extends Node

var defaultVolume : float = -35.0
var backgroundMusic = load("res://Resources/Music/last_fight.mp3")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_music():
	$backgroundMusic.stream = backgroundMusic
	$backgroundMusic.play()
	# Default to -30
	$backgroundMusic.volume_db = -35

func setMusicVolume(volume):
	if volume < 50:
		$backgroundMusic.volume_db = defaultVolume - (0.7 * (50.0 - float(volume)))
	elif volume > 50:
		$backgroundMusic.volume_db = defaultVolume + (0.7 * (float(volume) - 50.0))
	elif volume == 50:
		$backgroundMusic.volume_db = defaultVolume
	
