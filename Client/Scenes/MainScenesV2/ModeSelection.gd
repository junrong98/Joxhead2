extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	$usernameLabel.text = Global.username

func _on_singlePlayerButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/SinglePlayerMode.tscn")

func _on_multiPlayerButton_pressed():
	Server.getRooms()

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")
