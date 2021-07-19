extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	$usernameLabel.text = Global.username

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")

func _on_accountSettingButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/AccountSetting.tscn")

func _on_gamePlayButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/GameplaySetting.tscn")
