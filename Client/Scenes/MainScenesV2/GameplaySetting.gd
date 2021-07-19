extends TextureRect

func _ready():
	$usernameLabel.text = Global.username

func _on_controlButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ControlSetting.tscn")

func _on_soundButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/SoundSetting.tscn")

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Setting.tscn")
