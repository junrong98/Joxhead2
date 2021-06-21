extends Node2D

# Global
onready var hoverAudio = $MouseHover
onready var username = get_node("UsernameLabel")
var invData : Dictionary
onready var collection : FirestoreCollection = Firebase.Firestore.collection('users')

# Main menu
onready var mainLobbyContainer = get_node("MainLobby")

# Inventory
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var inventoryContainer = get_node("Inventory")
onready var invLabel = get_node("Inventory/Background/Item_Label")
onready var weaponSprite = get_node("Inventory/Background/Character_Sprite/Weapon_Sprite")
onready var dmgLabel = get_node("Inventory/StatsPanel/WpnDamageValue")
onready var rangeLabel = get_node("Inventory/StatsPanel/WpnRangeValue")
onready var ammoLabel = get_node("Inventory/StatsPanel/WpnAmmoValue" )
onready var disableIcon = get_node("Inventory/lock")
onready var statsPanel = get_node("Inventory/StatsPanel")
onready var unlockBtn = get_node("Inventory/StatsPanel/unlockBtn")
onready var creditLbl = get_node("Inventory/creditLbl")
onready var upgradeCostLbl = get_node("Inventory/StatsPanel/upgradeCostLbl")
onready var errLbl = get_node("Inventory/StatsPanel/errLbl")
onready var upgradeCostValLbl = get_node("Inventory/StatsPanel/upgradeCost")
onready var unlockCfmPanel = get_node("Inventory/unlockCfmPanel")
onready var unlockCostLbl = get_node("Inventory/StatsPanel/unlockCostLbl")
onready var unlockCost = get_node("Inventory/StatsPanel/unlockCost")
onready var statsPabelBtn = get_node("Inventory/StatsPanel")
onready var confirmUpBtn = get_node("Inventory/StatsPanel/ConfirmUpBtn")

var basic = preload("res://Resources/Weapon_Sprite/Basic.png")
var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var uzi = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")
var invStartPos = 0
var currWeapon
var upgradeCost = 0
var currWeaponRangeLvl
var currWeaponDmgLvl
var currWeaponAmmoLvl

# True if unlocking, false if upgrading
var unlckOrUpgrade

# Mode selection
onready var msContainer = get_node("ModeSelection")

# Single player lobby
onready var spContainer = get_node("SinglePlayerLobby")
onready var hsLabel = get_node("SinglePlayerLobby/VBoxContainer/HBoxContainer/HSValueLabel")

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
	username.text = Global.username
	hsLabel.text = str(Global.highscore)
	
	# Set player data	
	invData = Global.gamedata
	creditLbl.text = "Credit: " + str(invData["Credit"])

	setWpnLbls()
	setSwitch()
	
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

func _on_BackButton_pressed():
	upgradeCost = 0
	upgradeCostValLbl.text = str(upgradeCost)
	mainLobbyContainer.visible = true
	inventoryContainer.visible = false
	invStartPos = 0

func _on_ExitButton_pressed():
	rpc_id(1, "removePlayer", Global.uuid)
	Server.logout()

# Mode selection
func _on_msBackButton_pressed():
	mainLobbyContainer.visible = true
	msContainer.visible = false

func _on_SingleplayerButton_pressed():
	msContainer.visible = false
	spContainer.visible = true

func _on_MultiplayerButton_pressed():
	Server.getRooms()

# Single Player Lobby
func _on_SinglePlayerButton_mouse_entered():
	hoverAudio.play()

func _on_MultiPlayerButton_mouse_entered():
	hoverAudio.play()

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

# Inventory
func _on_LeftButton_mouse_entered():
	hoverAudio.play()

func _on_RightButton_mouse_entered():
	hoverAudio.play()

func setSwitch():
	if !(invData[currWeapon]["Unlocked"]):		
		for obj in statsPabelBtn.get_children():
			if "Button" in str(obj):
				obj.visible = false
				
		unlockBtn.visible = true
		unlockCostLbl.visible = true
		unlockCost.visible = true
		unlockCost.text = str(invData[currWeapon]["Unlocked_Cost"])
		upgradeCostValLbl.visible = false
		upgradeCostLbl.visible = false
		
	else:
		for obj in statsPabelBtn.get_children():
			if "Button" in str(obj):
				obj.visible = true
				
		unlockBtn.visible = false
		unlockCostLbl.visible = false
		unlockCost.visible = false
		unlockCost.text = str(0)
		upgradeCostValLbl.visible = true
		upgradeCostLbl.visible = true

		
func setWpnLbls():
	currWeapon = Global.invArr[invStartPos]
	invLabel.text = currWeapon
	weaponSprite.set_texture(Global.invSprite[invStartPos])
	dmgLabel.text = str(invData[currWeapon]["Dmg"])
	rangeLabel.text = str(invData[currWeapon]["Range"])
	ammoLabel.text = str(invData[currWeapon]["Ammo"])
	
	currWeaponDmgLvl = invData[currWeapon]["Dmg_Lvl"]
	currWeaponRangeLvl = invData[currWeapon]["Range_Lvl"]
	currWeaponAmmoLvl = invData[currWeapon]["Ammo_Lvl"]
	
	upgradeCost = 0
	upgradeCostValLbl.text = str(upgradeCost)

func _on_LeftButton_pressed():
	if invStartPos == 0:
		invStartPos = Global.invSize - 1
	else:
		invStartPos -= 1
	
	setWpnLbls()
	setSwitch()
	
		
func _on_RightButton_pressed():
	if invStartPos == Global.invSize - 1:
		invStartPos = 0
	else:
		invStartPos += 1

	setWpnLbls()
	setSwitch()

func updateUpgradeLabel():
	upgradeCostValLbl.text = str(upgradeCost)

func errCheck():
	if upgradeCost > invData["Credit"]:
		errLbl.visible = true
		return true
	else:
		errLbl.visible = false
		return false

func _on_dmgPlusBtn_pressed():
	currWeaponDmgLvl = currWeaponDmgLvl + 1
	upgradeCost = upgradeCost + currWeaponDmgLvl * invData[currWeapon]["Upgrade_Cost"]
	
	if errCheck():
		upgradeCost = upgradeCost - currWeaponDmgLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponDmgLvl = currWeaponDmgLvl - 1
	else:
		dmgLabel.text = str(int(dmgLabel.text) + 1)
		updateUpgradeLabel()

func _on_dmgMinusBtn_pressed():
	# Only can decrease if upgrade is greater than existing level
	if currWeaponDmgLvl != invData[currWeapon]["Dmg_Lvl"]:
		dmgLabel.text = str(int(dmgLabel.text) - 1)
		upgradeCost = upgradeCost - currWeaponDmgLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponDmgLvl = currWeaponDmgLvl - 1
		updateUpgradeLabel()
		
func _on_rangeMinusBtn_pressed():
	# Only can decrease if upgrade is greater than existing level
	if currWeaponRangeLvl != invData[currWeapon]["Range_Lvl"]:
		rangeLabel.text = str(int(rangeLabel.text) - 1)
		upgradeCost = upgradeCost - currWeaponRangeLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponRangeLvl = currWeaponRangeLvl - 1
		updateUpgradeLabel()

func _on_rangePlusBtn_pressed():
	currWeaponRangeLvl = currWeaponRangeLvl + 1
	upgradeCost = upgradeCost + currWeaponRangeLvl * invData[currWeapon]["Upgrade_Cost"]
	
	if errCheck():
		upgradeCost = upgradeCost - currWeaponRangeLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponRangeLvl = currWeaponRangeLvl - 1
	else:
		rangeLabel.text = str(int(rangeLabel.text) + 1)
		updateUpgradeLabel()

func _on_ammoMinusBtn_pressed():
	# Only can decrease if upgrade is greater than existing level
	if currWeaponAmmoLvl != invData[currWeapon]["Ammo_Lvl"]:
		ammoLabel.text = str(int(ammoLabel.text) - 1)
		upgradeCost = upgradeCost - currWeaponAmmoLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponAmmoLvl =  currWeaponAmmoLvl - 1
		updateUpgradeLabel()

func _on_ammoPlusBtn_pressed():
	currWeaponAmmoLvl =  currWeaponAmmoLvl + 1
	upgradeCost = upgradeCost +  currWeaponAmmoLvl * invData[currWeapon]["Upgrade_Cost"]
	
	if errCheck():
		upgradeCost = upgradeCost -  currWeaponAmmoLvl * invData[currWeapon]["Upgrade_Cost"]
		currWeaponAmmoLvl =  currWeaponAmmoLvl - 1
	else:
		ammoLabel.text = str(int(ammoLabel.text) + 1)
		updateUpgradeLabel()

func _on_unlockBtn_pressed():
	unlckOrUpgrade = true
	if invData[currWeapon]["Unlocked_Cost"] > invData["Credit"]:
		unlockCfmPanel.visible = false
	else:
		unlockCfmPanel.visible = true

func _on_ConfirmUpBtn_pressed():
	unlckOrUpgrade = false
	
	if upgradeCost > invData["Credit"]:
		errLbl.visible = true
		errLbl.text = "Not enought credit"
		unlockCfmPanel.visible = false
	elif upgradeCost == 0:
		errLbl.visible = true
		errLbl.text = "Nothing to upgrade"
		unlockCfmPanel.visible = false
	else:
		errLbl.visible = false
		unlockCfmPanel.visible = true
	
func _on_cfmBtn_pressed():
	if unlckOrUpgrade:
		invData[currWeapon]["Unlocked"] = true
		invData["Credit"] = invData["Credit"] - invData[currWeapon]["Unlocked_Cost"]
		invCollection.update("" + Global.uuid, {currWeapon : invData[currWeapon]})
		invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
		
	else:
		invData[currWeapon]["Ammo"] = invData[currWeapon]["Ammo"] + (currWeaponAmmoLvl - invData[currWeapon]["Ammo_Lvl"])
		invData[currWeapon]["Dmg"] = invData[currWeapon]["Dmg"] + (currWeaponDmgLvl - invData[currWeapon]["Dmg_Lvl"])
		invData[currWeapon]["Range"] = invData[currWeapon]["Range"] + (currWeaponRangeLvl - invData[currWeapon]["Range_Lvl"])
		
		invData[currWeapon]["Ammo_Lvl"] = currWeaponAmmoLvl
		invData[currWeapon]["Dmg_Lvl"] = currWeaponDmgLvl
		invData[currWeapon]["Range_Lvl"] = currWeaponRangeLvl
		invData["Credit"] = invData["Credit"] - upgradeCost
		
		invCollection.update("" + Global.uuid, {currWeapon : invData[currWeapon]})
		invCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
			
	unlockCfmPanel.visible = false
	updateGame()

func _on_cancelBtn_pressed():
	unlockCfmPanel.visible = false
	
	
# Settings

func _on_SettingButton_pressed():
	mainLobbyContainer.visible = false
	settingContainer.visible = true

func _on_settingBackButton_pressed():
	mainLobbyContainer.visible = true
	settingContainer.visible = false

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

func _on_AccountSettingButton_pressed():
	pass # Replace with function body.
	
func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
	$GameSetting/AudioSettings/SFXSlider.value = value

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	$GameSetting/AudioSettings/MusicSlider.value = value
