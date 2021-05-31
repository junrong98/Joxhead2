extends Node2D

# Global
onready var hoverAudio = $MouseHover
onready var username = get_node("UsernameLabel")
var invData : Dictionary
onready var collection : FirestoreCollection = Firebase.Firestore.collection('users')

# Main menu
onready var mainLobbyContainer = get_node("MainLobby")

# Button disabled
onready var LoadoutBtn : TextureButton = $MainLobby/MainContainer/VBoxContainer/LoadoutButton
onready var SettingBtn : TextureButton = $MainLobby/MainContainer/VBoxContainer/SettingButton

# Inventory
onready var inventoryContainer = get_node("Inventory")
onready var invLabel = get_node("Inventory/Background/Item_Label")
onready var weaponSprite = get_node("Inventory/Background/Character_Sprite/Weapon_Sprite")
onready var dmgLabel = get_node("Inventory/StatsPanel/WpnDamageValue")
onready var rangeLabel = get_node("Inventory/StatsPanel/WpnRangeValue")
onready var ammoLabel = get_node("Inventory/StatsPanel/WpnAmmoValue" )

var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var mp5 = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")

# Single player
onready var spContainer = get_node("SinglePlayerLobby")
onready var hsLabel = get_node("SinglePlayerLobby/VBoxContainer/HBoxContainer/HSValueLabel")

# Inventory
var invStartPos = 0
var currWeapon

# Scene load, update game with existing values stored in global script.
func _ready():
	LoadoutBtn.disabled = true
	SettingBtn.disabled = true
	updateGame()

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
	spContainer.visible = true

# Game menu
func _on_SinglePlayerButton_mouse_entered():
	hoverAudio.play()

func _on_MultiPlayerButton_mouse_entered():
	hoverAudio.play()

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

func _on_sp_BackButton_mouse_entered():
	hoverAudio.play()

func _on_sp_BackButton_pressed():
	mainLobbyContainer.visible = true
	spContainer.visible = false

func _on_StartMapButton_mouse_entered():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color("FF8784"))
	get_node("SinglePlayerLobby/sp_BackButton/BackgroundPanel").set('custom_styles/panel', new_style)

func _on_StartMapButton_mouse_exited():
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(1,1,1))
	get_node("SinglePlayerLobby/sp_BackButton/BackgroundPanel").set('custom_styles/panel', new_style)

func _on_StartMapButton_pressed():
	Global.game_highscore = 0
	get_tree().change_scene("res://Scenes/GameScene/" + "World.tscn")

func _on_ExitButton_pressed():
	Server.logout()


