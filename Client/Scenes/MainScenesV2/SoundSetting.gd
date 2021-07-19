extends TextureRect

onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')

var regex = RegEx.new()
var oldText = ""
var text
var isSave = true
var originalBgVol
var originalSFXVol

func _ready():
	originalBgVol = Global.currentBgVolume
	originalSFXVol = Global.currentSFXvoume
	regex.compile("^[0-9]*$")

	$bgMusicSlider.value = Global.currentBgVolume
	$bgMusicVolInput.text = str($bgMusicSlider.value)
	$sfxSlider.value = Global.currentSFXvoume
	$sfxVolInput.text = str($sfxSlider.value)
	$usernameLabel.text = Global.username

func _on_bgMusicSlider_value_changed(value):
	$bgMusicVolInput.text = str($bgMusicSlider.value)
	BackgroundMusic.setMusicVolume($bgMusicSlider.value)
	Global.currentBgVolume = float($bgMusicSlider.value)
	
	if value != originalBgVol:
		isSave = false
		
func _on_bgMusicVolInput_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		oldText = text
	else:
		text = oldText
	$bgMusicSlider.value = int($bgMusicVolInput.text)
	Global.currentBgVolume = float($bgMusicSlider.value)
	
	if $bgMusicSlider.value != originalBgVol:
		isSave = false
		

func _on_sfxSlider_value_changed(value):
	# Original was from -80 to 10
	# So we take current value and do a -70
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value - 70)
	$sfxVolInput.text = str(value)
	Global.currentSFXvoume = value
	
	if value != originalSFXVol:
		isSave = false

func _on_sfxVolInput_text_changed(new_text):
	if regex.search(new_text):
		text = new_text   
		oldText = text
	else:
		text = oldText
	$sfxSlider.value = int($sfxVolInput.text)
	Global.currentSFXvoume = $sfxSlider.value
	
	if $sfxSlider.value != originalSFXVol:
		isSave = false

func _on_backButton_pressed():
	if !(isSave):
		$confirmationPanel.visible = true
		$conPanel.visible = true
	else:
		get_tree().change_scene("res://Scenes/MainScenesV2/GameplaySetting.tscn")

func _on_saveSettings_pressed():
	isSave = true
	if isSave:
		Global.currentSFXvoume = $sfxSlider.value
		Global.currentBgVolume = $bgMusicSlider.value
		Global.settings['sound']['backgroundMusicVolume'] = Global.currentBgVolume
		Global.settings['sound']['sfxVolume'] = Global.currentSFXvoume
		userCollection.update(Global.uuid, {"highscore" : Global.highscore, "username" : Global.username, "settings" : Global.settings})

func _on_noButton_pressed():
	$confirmationPanel.visible = false
	$conPanel.visible = false

func _on_confirmationButton_pressed():
	BackgroundMusic.setMusicVolume(Global.currentBgVolume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.currentSFXvoume - 70)
	get_tree().change_scene("res://Scenes/MainScenesV2/GameplaySetting.tscn")
