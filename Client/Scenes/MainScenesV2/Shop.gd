extends TextureRect

# Thread
var dmgThread
var rangeThread
var ammoThread

# Preload images
var disabledUpgradeTexture = preload("res://ResourcesV2/Images/UpgradeDisabled.png")
var enabledUpgradeInactiveTexture = preload("res://ResourcesV2/Images/UpgradeInactive.png")
var enabledUpgradeActiveTexture = preload("res://ResourcesV2/Images/upgradeActive.png")

# Data
onready var userInventoryCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var invData = Global.gamedata

onready var creditLbl = $creditLbl
onready var descriptionText = $encapContainer/descriptionTextLabel
onready var encapContainer = $encapContainer
onready var damageProgress = $encapContainer/damageProgress
onready var rangeProgress = $encapContainer/rangeProgress
onready var ammoProgress = $encapContainer/ammoProgress
onready var itemProgress = $encapItemContainer/itemStatsProgress
onready var errLbl = $encapContainer/errLabel
onready var dmgValLbl = $encapContainer/damageValLabel
onready var ammoValLbl = $encapContainer/ammoValLabel
onready var rangeValLbl = $encapContainer/rangeValLabel
onready var itemValLbl = $encapItemContainer/itemValLabel

onready var upgradeDmgLvl = 0
onready var upgradeRangeLvl = 0
onready var upgradeAmmoLvl = 0
onready var totalCost = 0
onready var totalUpgradeLvl = 0

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

# Variables
var currObj
var checkPnlAniPlayed = 0 # 0 means animation not played
var totalItemCost = 0
var isClicked = false

func _ready():
	creditLbl.text = str(invData["Credit"])
	$usernameLabel.text = Global.username
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")
	Server.network.connect("connection_failed", self, "_on_connection_failed")
	Server.maintainConnection()

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)
	
func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func populateItemDescription():
	$encapItemContainer/descriptionTextLabel.text = invData[currObj]["Description"]

func getItemStats(type):
	playPnlItemAnimation()
	populateItemDescription()
	if type == "HEALTH":
		$encapItemContainer/itemLabel.text = "Health"
		itemProgress(invData[currObj]["Ammo"])
	else:
		$encapItemContainer/itemLabel.text = "Damage"
		itemProgress(invData[currObj]["Dmg"])
	$encapItemContainer/itemsCurrentVal.text = str(invData[currObj]["Ammo"])
	
func itemProgress(itemStats):
	for n in itemStats:
		if itemStats < itemProgress.value:
			itemProgress.value-=1
			itemValLbl.text = str(itemProgress.value)
		elif itemStats > itemProgress.value:
			itemProgress.value+=1
			itemValLbl.text = str(itemProgress.value)
		else:
			break
		yield(get_tree().create_timer(0.01),"timeout")

func _on_barrelButton_pressed():
	resetItem()
	$encapItemContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = 'Barrel'
	getItemStats("Weapon")

func _on_wallsButton_pressed():
	resetItem()
	$encapItemContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = 'Fake_Wall'
	getItemStats("HEALTH")

func _on_minesButton_pressed():
	resetItem()
	$encapItemContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = 'Mine'
	getItemStats("Weapon")

func _on_grenadeButton_pressed():
	resetItem()
	$encapItemContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = 'Grenade'
	getItemStats("Weapon")
		
func playPnlItemAnimation():
	disRestLbl()
	if !(checkPnlAniPlayed):
		encapContainer.visible = false
		$weaponSelectAnimationPlayer.play("moveContainer")
		checkPnlAniPlayed = 1

func damageProgress(dmgStats):
	for n in dmgStats:
		if dmgStats < damageProgress.value:
			damageProgress.value-=1
			dmgValLbl.text = str(damageProgress.value)
		elif dmgStats > damageProgress.value:
			damageProgress.value+=1
			dmgValLbl.text = str(damageProgress.value)
		else:
			break
		yield(get_tree().create_timer(0.01),"timeout")
	#dmgThread.wait_to_finish()

func costAnimation(cost):
	if $costAnimationPlayer.is_playing():
		$costAnimationPlayer.stop("costFadeDrag")
	$costLbl.visible = true
	$costLbl.text = "-" + str(cost)
	$costAnimationPlayer.play("costFadeDrag")
	
func rangeProgress(rangeStats):
	for n in rangeStats:
		if rangeStats < rangeProgress.value:
			rangeProgress.value-=1
			rangeValLbl.text = str(rangeProgress.value)
		elif rangeStats > rangeProgress.value:
			rangeProgress.value+=1
			rangeValLbl.text = str(rangeProgress.value)
		else:
			break
		yield(get_tree().create_timer(0.01),"timeout")
	#rangeThread.wait_to_finish()
	
func ammoProgress(ammoStats):
	for n in (ammoStats / 10):
		if ammoStats < ammoProgress.value:
			ammoProgress.value-=10
			ammoValLbl.text = str(ammoProgress.value)
		elif ammoStats > ammoProgress.value:
			ammoProgress.value+=10
			ammoValLbl.text = str(ammoProgress.value)
		else:
			break
		yield(get_tree().create_timer(0.01),"timeout")
	#ammoThread.wait_to_finish()
	
func checkUnlocked(weapon):
	# Check if weapon has been purchased
	if !(invData[weapon]["Unlocked"]):
		$encapContainer/weaponCostValLabel.visible = true
		$encapContainer/weaponCostLabel.visible = true
		$encapContainer/purchaseButton.visible = true
		$encapContainer/ownedButton.visible = false
	else:
		$encapContainer/weaponCostValLabel.visible = false
		$encapContainer/weaponCostLabel.visible = false
		$encapContainer/purchaseButton.visible = false
		$encapContainer/ownedButton.visible = true
		
func populateDescription(weapon):
	descriptionText.text = invData[weapon]["Description"]
	checkUnlocked(weapon)
	

func getStats(weapon):
	damageProgress(Global.weaponStats[weapon]["Dmg"])
	rangeProgress(Global.weaponStats[weapon]["Range"])
	ammoProgress(Global.weaponStats[weapon]["Ammo"])
	$encapContainer/weaponCostValLabel.text = str(Global.weaponStats[weapon]["Unlocked_Cost"])

func disRestLbl():
	errLbl.visible = false
	
func playPnlAnimation():
	disRestLbl()
	if !(checkPnlAniPlayed):
		encapContainer.visible = true
		$weaponSelectAnimationPlayer.play("moveContainer")
		checkPnlAniPlayed = 1
	populateDescription(currObj)
	getStats(currObj)

func _on_ak47Button_pressed():
	$encapContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = "AK47"
	playPnlAnimation()

func _on_mp5Button_pressed():
	$encapContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = "Uzi"
	playPnlAnimation()
	
func _on_spas12Button_pressed():
	$encapContainer.visible = true
	$clickContainer.visible = false
	isClicked = true
	currObj = "SPAS12"
	playPnlAnimation()

func addTextToErr(message, lblColor):
	errLbl.visible = true
	errLbl.text = message
	errLbl.add_color_override("font_color", lblColor)
	
func _on_purchaseButton_pressed():
	var currWeaponCost = invData[currObj]["Unlocked_Cost"]
	
	if currWeaponCost > invData["Credit"]:
		addTextToErr("Insufficient credit", Color(1, 0, 0))
	else:
		addTextToErr("Purchase successfully", Color(0, 1, 0))
		invData[currObj]["Unlocked"] = true
		invData["Credit"] = invData["Credit"] - currWeaponCost
		userInventoryCollection.update("" + Global.uuid, {currObj  : invData[currObj]})
		userInventoryCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
		creditLbl.text = str(invData["Credit"])
		costAnimation(currWeaponCost)
		checkUnlocked(currObj)

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")

func _on_itemButton_pressed():
	$weaponPanel.visible = false
	$itemPanel.visible = true
	$encapContainer.visible = false
	$encapItemContainer.visible = true
	
	if isClicked:
		$encapItemContainer.visible = false
		$clickContainer.visible = true
	

func _on_weaponButton_pressed():
	$weaponPanel.visible = true
	$itemPanel.visible = false
	$encapItemContainer.visible = false
	$encapContainer.visible = true
	
	if isClicked:
		$encapContainer.visible = false
		$clickContainer.visible = true

func resetItem():
	totalItemCost = 0
	$encapItemContainer/qtyPurchaseValLbl.text = '0'
	$encapItemContainer/costValLbl.text = '0'

func _on_increaseQtyButton_pressed():
	var currVal = int($encapItemContainer/qtyPurchaseValLbl.text)
	
	if currVal != 99:
		currVal = currVal + 1
		$encapItemContainer/qtyPurchaseValLbl.text = str(currVal)
		totalItemCost = totalItemCost + invData[currObj]['Price']
		$encapItemContainer/costValLbl.text = str(totalItemCost)

func _on_decreaseQtyButton_pressed():
	var currVal = int($encapItemContainer/qtyPurchaseValLbl.text)
	
	if currVal != 0:
		currVal = currVal - 1
		$encapItemContainer/qtyPurchaseValLbl.text = str(currVal)
		totalItemCost = totalItemCost - invData[currObj]['Price']
		$encapItemContainer/costValLbl.text = str(totalItemCost)

func _on_purchaseItemButton_pressed():
	if totalItemCost != 0:
		if totalItemCost > invData["Credit"]:
			$encapItemContainer/errLabel.visible = true
			$encapItemContainer/errLabel.text = "Not enough credit"
		else:
			invData["Credit"] = invData["Credit"] - totalItemCost
			invData[currObj]['Ammo'] = invData[currObj]['Ammo'] + int($encapItemContainer/qtyPurchaseValLbl.text)
			userInventoryCollection.update("" + Global.uuid, {currObj  : invData[currObj]})
			userInventoryCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
			creditLbl.text = str(invData["Credit"])
			$encapItemContainer/itemsCurrentVal.text = str(invData[currObj]['Ammo'])
			costAnimation(totalItemCost)
			resetItem()
