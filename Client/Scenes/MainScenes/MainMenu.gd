extends Node2D

# Global
onready var hoverAudio = $MouseHover
onready var username = get_node("UsernameLabel")
var invData : Dictionary
onready var collection : FirestoreCollection = Firebase.Firestore.collection('users')

# Main menu
onready var mainLobbyContainer = get_node("MainLobby")

# Inventory
onready var inventoryContainer = get_node("Inventory")
onready var invLabel = get_node("Inventory/Background/Item_Label")
onready var weaponSprite = get_node("Inventory/Background/Character_Sprite/Weapon_Sprite")
onready var dmgLabel = get_node("Inventory/StatsPanel/WpnDamageValue")
onready var rangeLabel = get_node("Inventory/StatsPanel/WpnRangeValue")
onready var ammoLabel = get_node("Inventory/StatsPanel/WpnAmmoValue" )

var basic = preload("res://Resources/Weapon_Sprite/Basic.png")
var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var uzi = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")

# Mode selection
onready var msContainer = get_node("ModeSelection")

# Single player lobby
onready var spContainer = get_node("SinglePlayerLobby")
onready var hsLabel = get_node("SinglePlayerLobby/VBoxContainer/HBoxContainer/HSValueLabel")

# Inventory
var invStartPos = 0
var currWeapon

# Map related variables
var map_num = 0
var mapArr = ["SinglePlayerLobby/BackgroundPanel/StartMapButton1", "SinglePlayerLobby/BackgroundPanel/StartMapButton2", "SinglePlayerLobby/BackgroundPanel/StartMapButton3"]
var curr_map = mapArr[map_num]
onready var currMap = get_node(curr_map)
var max_num_map = mapArr.size()
var previousMap

# Settings
onready var settingContainer = get_node("Settings")
onready var gameSetting = get_node("GameSetting")
onready var controlSetting = get_node("GameSetting/guikeybinding/ControlSettings")
onready var audioSetting = get_node("GameSetting/AudioSettings")

# Scene load, update game with existing values stored in global script.
func _ready():
	updateGame()
	$BackgroundMusic.play()

# Update the game with existing/newest data.
func updateGame():
	hsLabel.text = str(Global.highscore)
	invData = Global.gamedata
	username.text = Global.username
	currWeapon = Global.invArr[invStartPos]
	invLabel.text = currWeapon
	weaponSprite.set_texture(Global.invSprite[invStartPos])
	dmgLabel.text = str(invData[currWeapon + "_Dmg"])
	rangeLabel.text = str(invData[currWeapon + "_Range"])
	ammoLabel.text = str(invData[currWeapon + "_Ammo"])
	
	# If highscore needs to be updated.
	if Global.updateHighScore:
		var up_task : FirestoreTask = collection.update("" + Global.uuid, {"highscore" : Global.highscore, "username" : Global.username})
		Global.updateHighScore = false
		
# Main menu
func _on_StartButton_mouse_entered():
	hoverAudio.play()	
	
func _on_LoadoutButton_mouse_entered():
	hoverAudio.play()
	
func _on_SettingButton_mouse_entered():
	hoverAudio.play()

func _on_ExitButton_mouse_entered():
	hoverAudio.play()

func _on_LoadoutButton_pressed():
	mainLobbyContainer.visible = true
	inventoryContainer.visible = true

func _on_StartButton_pressed():
	mainLobbyContainer.visible = false
	msContainer.visible = true

# Mode selection
func _on_msBackButton_pressed():
	mainLobbyContainer.visible = true
	msContainer.visible = false

func _on_SingleplayerButton_pressed():
	msContainer.visible = false
	spContainer.visible = true

func _on_SingleplayerButton_mouse_entered():
	hoverAudio.play()

func _on_MultiplayerButton_pressed():
	Server.getRooms()

func _on_MultiplayerButton_mouse_entered():
	hoverAudio.play()

# Single Player Lobby	
func _on_sp_BackButton_mouse_entered():
	hoverAudio.play()

func _on_sp_BackButton_pressed():
	msContainer.visible = true
	spContainer.visible = false

func _on_StartMapButton1_mouse_entered():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color("FF8784"))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)

func _on_StartMapButton1_mouse_exited():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(1,1,1))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)

func _on_StartMapButton1_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/" + "World1.tscn")

# Inventory
func _on_LeftButton_mouse_entered():
	hoverAudio.play()

func _on_RightButton_mouse_entered():
	hoverAudio.play()

func _on_LeftButton_pressed():
	if invStartPos == 0:
		invStartPos = Global.invSize - 1
	else:
		invStartPos -= 1

	var currWeapon = Global.invArr[invStartPos]
	invLabel.text = currWeapon
	weaponSprite.set_texture(Global.invSprite[invStartPos])
	dmgLabel.text = str(invData[currWeapon + "_Dmg"])
	rangeLabel.text = str(invData[currWeapon + "_Range"])
	ammoLabel.text = str(invData[currWeapon + "_Ammo"])
			
func _on_RightButton_pressed():
	if invStartPos == Global.invSize - 1:
		invStartPos = 0
	else:
		invStartPos += 1

	var currWeapon = Global.invArr[invStartPos]
	invLabel.text = currWeapon
	weaponSprite.set_texture(Global.invSprite[invStartPos])
	dmgLabel.text = str(invData[currWeapon + "_Dmg"])
	rangeLabel.text = str(invData[currWeapon + "_Range"])
	ammoLabel.text = str(invData[currWeapon + "_Ammo"])
	
func _on_BackButton_pressed():
	mainLobbyContainer.visible = true
	inventoryContainer.visible = false
	invStartPos = 0

func _on_ExitButton_pressed():
	rpc_id(1, "removePlayer", Global.uuid)
	Server.logout()

func _on_Test_pressed():
	Server.test()

func _on_SettingButton_pressed():
	mainLobbyContainer.visible = false
	settingContainer.visible = true

func _on_StartMapButton2_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/" + "World2.tscn")

func _on_StartMapButton2_mouse_entered():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color("FF8784"))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)


func _on_StartMapButton2_mouse_exited():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(1,1,1))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)


func _on_NextMapButton_pressed():
	if map_num == max_num_map - 1:
		map_num == 0
	else:
		map_num += 1
	curr_map = mapArr[map_num]
	previousMap = currMap
	previousMap.visible = false
	currMap = get_node(curr_map)
	currMap.visible = true


func _on_PreviousMapButton_pressed():
	if map_num == 0:
		map_num == max_num_map - 1
	else:
		map_num -= 1
	curr_map = mapArr[map_num]
	previousMap = currMap
	previousMap.visible = false
	currMap = get_node(curr_map)
	currMap.visible = true


func _on_NextMapButton_mouse_entered():
	hoverAudio.play()

func _on_PreviousMapButton_mouse_entered():
	hoverAudio.play()


func _on_StartMapButton3_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/" + "World3.tscn")


func _on_StartMapButton3_mouse_entered():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color("FF8784"))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)


func _on_StartMapButton3_mouse_exited():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(1,1,1))
	get_node("SinglePlayerLobby/BackgroundPanel").set('custom_styles/panel', new_style)


func _on_settingBackButton_pressed():
	mainLobbyContainer.visible = true
	settingContainer.visible = false


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	$GameSetting/AudioSettings/SFXSlider.value = value


func _on_GameSettingButton_pressed():
	settingContainer.visible = false
	gameSetting.visible = true

func _on_GameSettingButton_mouse_entered():
	hoverAudio.play()

func _on_AccountSettingButton_mouse_entered():
	hoverAudio.play()

func _on_gsBackButton_pressed():
	gameSetting.visible = false
	settingContainer.visible = true
	controlSetting.visible = false
	audioSetting.visible = false


func _on_gsBackButton_mouse_entered():
	hoverAudio.play()


func _on_settingBackButton_mouse_entered():
	hoverAudio.play()


func _on_ControlSettingButton_pressed():
	controlSetting.visible = true
	audioSetting.visible = false


func _on_AudioSettingButton_pressed():
	controlSetting.visible = false
	audioSetting.visible = true
	

func _on_HSlider2_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	$GameSetting/AudioSettings/MusicSlider.value = value
