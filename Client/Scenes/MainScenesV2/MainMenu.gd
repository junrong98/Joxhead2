extends TextureRect

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$usernameLabel.text = Global.username
	if Global.roomName: # If room name is here
		Server.clearRoom()
	Global.resetMultiplayerData()
	
	# Load how to play to player settings
	$howToPlayPanel/page1/upLbl.text = OS.get_scancode_string(Global.controlSettings["up_W"])
	$howToPlayPanel/page1/downLbl.text = OS.get_scancode_string(Global.controlSettings["down_S"])
	$howToPlayPanel/page1/leftLbl.text = OS.get_scancode_string(Global.controlSettings["left_A"])
	$howToPlayPanel/page1/rightLbl.text = OS.get_scancode_string(Global.controlSettings["right_D"])
	$howToPlayPanel/page1/nextLbl.text = OS.get_scancode_string(Global.controlSettings["next_weapon"])
	$howToPlayPanel/page1/prevLbl.text = OS.get_scancode_string(Global.controlSettings["previous_weapon"])
	$howToPlayPanel/page1/landmineLbl.text = OS.get_scancode_string(Global.controlSettings["plant_landmine"])
	$howToPlayPanel/page1/grenadeLbl.text = OS.get_scancode_string(Global.controlSettings["throw_item"])
	$howToPlayPanel/page1/wallsLbl.text = OS.get_scancode_string(Global.controlSettings["place_fakewall"])
	$howToPlayPanel/page1/barrelLbl.text = OS.get_scancode_string(Global.controlSettings["place_barrel"])

	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")
	Server.maintainConnection()

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_shopButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Shop.tscn")

func _on_inventoryButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Inventory.tscn")

func _on_settingsButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Setting.tscn")

func _on_playButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ModeSelection.tscn")

func _on_exitButton_pressed():
	Server.logout()

func _on_howToPlayLabel_pressed():
	$howToPlayBgPanel.visible = true
	$howToPlayPanel.visible = true

func _on_howtoplayexitButton_pressed():
	$howToPlayBgPanel.visible = false
	$howToPlayPanel.visible = false

func _on_nextPageButton_pressed():
	$howToPlayPanel/page1.visible = false
	$howToPlayPanel/page2.visible= true
	$howToPlayPanel/nextPageButton.visible = false
	$howToPlayPanel/prevPageButton.visible = true

func _on_prevPageButton_pressed():
	$howToPlayPanel/page1.visible = true
	$howToPlayPanel/page2.visible= false
	$howToPlayPanel/nextPageButton.visible = true
	$howToPlayPanel/prevPageButton.visible = false
