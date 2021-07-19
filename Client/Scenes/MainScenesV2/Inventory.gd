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
onready var dmgLvlLbl = $encapContainer/damageLvlLbl
onready var rangeLvlLbl = $encapContainer/rangeLvlLbl
onready var ammoLvlLbl = $encapContainer/ammoLvlLbl

# Upgrade
onready var upgradedDmgLbl = $encapContainer/upgradedDmgLbl
onready var upgradedRangeLbl = $encapContainer/upgradedRangeLbl
onready var upgradedAmmoLbl = $encapContainer/upgradedAmmoLbl
onready var upgradedDmgValLbl = $encapContainer/upgradedDmgValLbl
onready var upgradedRangeValLbl = $encapContainer/upgradedRangeValLbl
onready var upgradedAmmoValLbl = $encapContainer/upgradedAmmoValLbl
onready var totalCostLbl = $encapContainer/totalCostValLabel
onready var upgradeButton = $encapContainer/upgradeButton

onready var upgradeDmgLvl = 0
onready var upgradeRangeLvl = 0
onready var upgradeAmmoLvl = 0
onready var totalCost = 0
onready var totalUpgradeLvl = 0


# Variables
var currObj
var checkPnlAniPlayed = 0 # 0 means animation not played
var isClicked = false

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

func costAnimation(cost):	
	if $costAnimationPlayer.is_playing():
		$costAnimationPlayer.stop("costFadeDrag")
	$costLbl.visible = true
	$costLbl.text = "-" + str(cost)
	$costAnimationPlayer.play("costFadeDrag")
	creditLbl.text = str(invData["Credit"])

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

func _ready():
	creditLbl.text = str(invData["Credit"])
	
func checkUnlocked(weapon):
	# Check if weapon has been purchased
	if invData[weapon]["Unlocked"]:
		upgradeButton.visible = true
		$encapContainer/notAvailButton.visible = false
		$encapContainer/totalCostLabel.visible = true
		$encapContainer/totalCostValLabel.visible = true
		$upgradeContainer.visible = true
	else:
		upgradeButton.visible = false
		$encapContainer/notAvailButton.visible = true
		$encapContainer/totalCostLabel.visible = false
		$encapContainer/totalCostValLabel.visible = false
		$upgradeContainer.visible = false
				
func populateDescription(weapon):
	descriptionText.text = invData[weapon]["Description"]
	checkUnlocked(weapon)

func getStats(weapon):
	damageProgress(invData[weapon]["Dmg"])
	rangeProgress(invData[weapon]["Range"])
	ammoProgress(invData[weapon]["Ammo"])
	#dmgThread = Thread.new()
	#rangeThread = Thread.new()
	#ammoThread = Thread.new()
	
	#dmgLvlLbl.text = "Lv." + str(invData[weapon]["Dmg_Lvl"])
	#rangeLvlLbl.text = "Lv." + str(invData[weapon]["Range_Lvl"])
	#ammoLvlLbl.text = "Lv." + str(invData[weapon]["Ammo_Lvl"])
	
	#dmgThread.start(self, "damageProgress", invData[weapon]["Dmg"])
	#rangeThread.start(self, "rangeProgress", invData[weapon]["Range"])
	#ammoThread.start(self, "ammoProgress", invData[weapon]["Ammo"])

func disRestLbl():
	errLbl.visible = false
	
func playPnlItemAnimation():
	disRestLbl()
	if !(checkPnlAniPlayed):
		encapContainer.visible = false
		$weaponSelectAnimationPlayer.play("moveContainer")
		checkPnlAniPlayed = 1
	
func playPnlAnimation():
	disRestLbl()
	if !(checkPnlAniPlayed):
		encapContainer.visible = true
		$weaponSelectAnimationPlayer.play("moveContainer")
		checkPnlAniPlayed = 1
	populateDescription(currObj)
	getStats(currObj)

func _on_basicButton_pressed():
	currObj = "Basic"
	isClicked = true
	$clickContainer.visible = false
	$encapContainer.visible = true
	playPnlAnimation()

func _on_ak47Button_pressed():
	currObj = "AK47"
	isClicked = true
	$clickContainer.visible = false
	$encapContainer.visible = true
	playPnlAnimation()

func _on_mp5Button_pressed():
	currObj = "Uzi"
	isClicked = true
	$clickContainer.visible = false
	$encapContainer.visible = true
	playPnlAnimation()
	
func _on_spas12Button_pressed():
	currObj = "SPAS12"
	isClicked = true
	$clickContainer.visible = false
	$encapContainer.visible = true
	playPnlAnimation()

func addTextToErr(message, lblColor):
	errLbl.visible = true
	errLbl.text = message
	errLbl.add_color_override("font_color", lblColor)

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/MainMenu.tscn")
	
#Upgrade
func getTotalCost(cost, isUpgrade):
	for i in cost:
		if isUpgrade: # The user is upgrading the gun
			totalCost+=1
			totalCostLbl.bbcode_text = '[center][u]' + str(totalCost) + '[/u][/center]'
		else: # The user is reverting their upgrade
			totalCost-=1
			totalCostLbl.bbcode_text = '[center][u]' + str(totalCost) + '[/u][/center]'
		yield(get_tree().create_timer(0.003),"timeout")

func upgradeBtnDisabled():
	upgradeButton.set_normal_texture(disabledUpgradeTexture)
	upgradeButton.set_hover_texture(disabledUpgradeTexture)
	upgradeButton.disabled = true

func upgradeBtnEnabled():
	upgradeButton.set_normal_texture(enabledUpgradeInactiveTexture)
	upgradeButton.set_hover_texture(enabledUpgradeActiveTexture)
	upgradeButton.disabled = false

func _on_upgradeDmgButton_pressed():
	upgradeBtnEnabled()
	upgradedDmgLbl.visible = true
	upgradedDmgValLbl.visible = true
	upgradeDmgLvl+= 1
	totalUpgradeLvl+=1
	upgradedDmgLbl.text = "+ " + str(upgradeDmgLvl)
	for i in 2:
		var currUpgradedDmgVal = int(upgradedDmgValLbl.text)
		var newUpgradedDmgVal = currUpgradedDmgVal + 1
		upgradedDmgValLbl.text = "+ " + str(newUpgradedDmgVal)
		yield(get_tree().create_timer(0.003),"timeout")
	var totalDmgCost = invData[currObj]["Upgrade_Cost"] 
	getTotalCost(totalDmgCost, true)

func _on_upgradeRangeButton_pressed():
	upgradeBtnEnabled()
	upgradedRangeLbl.visible = true
	upgradedRangeValLbl.visible = true
	upgradeRangeLvl+= 1
	totalUpgradeLvl+=1
	upgradedRangeLbl.text = "+ " + str(upgradeRangeLvl)
	for i in 2:
		var currUpgradedRangeVal = int(upgradedRangeValLbl.text)
		var newUpgradedRangeVal = currUpgradedRangeVal + 1
		upgradedRangeValLbl.text = "+ " + str(newUpgradedRangeVal)
		yield(get_tree().create_timer(0.003),"timeout")
	var totalRangeCost = invData[currObj]["Upgrade_Cost"] 
	getTotalCost(totalRangeCost, true)

func _on_upgradeAmmoButton_pressed():
	upgradeBtnEnabled()
	upgradedAmmoLbl.visible = true
	upgradedAmmoValLbl.visible = true
	upgradeAmmoLvl+= 1
	totalUpgradeLvl+=1
	upgradedAmmoLbl.text = "+ " + str(upgradeAmmoLvl)
	for i in 10:
		var currUpgradedAmmoVal = int(upgradedAmmoValLbl.text)
		var newUpgradedAmmoVal = currUpgradedAmmoVal + 1
		upgradedAmmoValLbl.text = "+ " + str(newUpgradedAmmoVal)
		yield(get_tree().create_timer(0.003),"timeout")
	var totalAmmoCost = invData[currObj]["Upgrade_Cost"] 
	getTotalCost(totalAmmoCost, true)

func _on_downgradeDmgButton_pressed():
	totalUpgradeLvl-=1
	upgradeDmgLvl-= 1
	if totalUpgradeLvl <= 0: # upgraded level = 0
		upgradeBtnDisabled()
	if upgradeDmgLvl > 0:
		upgradedDmgLbl.text = "+ " + str(upgradeDmgLvl)
		for i in 3:
			var currUpgradedDmgVal = int(upgradedDmgValLbl.text)
			var newUpgradedDmgVal = currUpgradedDmgVal - 1
			upgradedDmgValLbl.text = "+ " + str(newUpgradedDmgVal)
			yield(get_tree().create_timer(0.003),"timeout")
		var totalDmgCost = invData[currObj]["Upgrade_Cost"] 
		getTotalCost(totalDmgCost, false)
	else:
		upgradedDmgLbl.visible = false
		upgradedDmgValLbl.visible = false

func _on_downgradeRangeButton_pressed():
	totalUpgradeLvl-=1
	upgradeRangeLvl-= 1
	if totalUpgradeLvl <= 0: # upgraded level = 0
		upgradeBtnDisabled()		
	if upgradeRangeLvl > 0:
		upgradedRangeLbl.text = "+ " + str(upgradeRangeLvl)
		for i in 3:
			var currUpgradedRangeVal = int(upgradedRangeValLbl.text)
			var newUpgradedRangeVal = currUpgradedRangeVal - 1
			upgradedRangeValLbl.text = "+ " + str(newUpgradedRangeVal)
			yield(get_tree().create_timer(0.003),"timeout")
		var totalRangeCost = invData[currObj]["Upgrade_Cost"] 
		getTotalCost(totalRangeCost, false)
	else:
		upgradedRangeLbl.visible = false
		upgradedRangeValLbl.visible = false

func _on_downgradeAmmoButton_pressed():
	totalUpgradeLvl-=1
	upgradeAmmoLvl-= 1
	if totalUpgradeLvl <= 0: # upgraded level = 0
		upgradeBtnDisabled()
	if upgradeAmmoLvl > 0:
		upgradedAmmoLbl.text = "+ " + str(upgradeAmmoLvl)
		for i in 3:
			var currUpgradedAmmoVal = int(upgradedAmmoValLbl.text)
			var newUpgradedAmmoVal = currUpgradedAmmoVal - 1
			upgradedAmmoValLbl.text = "+ " + str(newUpgradedAmmoVal)
			yield(get_tree().create_timer(0.003),"timeout")
		var totalAmmoCost = invData[currObj]["Upgrade_Cost"] 
		getTotalCost(totalAmmoCost, false)
	else:
		upgradedAmmoLbl.visible = false
		upgradedAmmoValLbl.visible = false

func resetUpgradeForm():
	upgradeBtnDisabled()
	getStats(currObj)
	costAnimation(totalCost)
	
	upgradeDmgLvl = 0
	upgradeRangeLvl = 0
	upgradeAmmoLvl = 0
	totalCost = 0
	totalUpgradeLvl = 0
	
	upgradedDmgLbl.visible = false
	upgradedDmgValLbl.visible = false
	upgradedRangeLbl.visible = false
	upgradedRangeValLbl.visible = false
	upgradedAmmoLbl.visible = false
	upgradedAmmoValLbl.visible = false
	
	totalCostLbl.bbcode_text = '[center][u]' + str(0) + '[/u][/center]'

func _on_upgradeButton_pressed():
	invData[currObj]["Dmg_Lvl"] = invData[currObj]["Dmg_Lvl"] + upgradeDmgLvl
	invData[currObj]["Range_Lvl"] = invData[currObj]["Range_Lvl"] + upgradeRangeLvl
	invData[currObj]["Ammo_Lvl"] = invData[currObj]["Ammo_Lvl"] + upgradeAmmoLvl
	
	invData[currObj]["Dmg"] = invData[currObj]["Dmg"] + (upgradeDmgLvl * 2)
	invData[currObj]["Range"] = invData[currObj]["Range"] + (upgradeRangeLvl * 2)
	invData[currObj]["Ammo"] = invData[currObj]["Ammo"] + (upgradeAmmoLvl * 10)
	
	invData["Credit"] = invData["Credit"] - totalCost
	userInventoryCollection.update("" + Global.uuid, {currObj : invData[currObj]})
	userInventoryCollection.update("" + Global.uuid, {"Credit" : invData["Credit"]})
	resetUpgradeForm()


func _on_itemButton_pressed():
	$weaponPanel.visible = false
	$itemPanel.visible = true
	$encapContainer.visible = false
	$encapItemContainer.visible = true
	$upgradeContainer.visible = false
	
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
		$upgradeContainer.visible = false
		$clickContainer.visible = true

func _on_barrelButton_pressed():
	currObj = 'Barrel'
	isClicked = true
	$clickContainer.visible = false
	$encapItemContainer.visible = true
	getItemStats("Weapon")

func _on_wallsButton_pressed():
	currObj = 'Fake_Wall'
	isClicked = true
	$clickContainer.visible = false
	$encapItemContainer.visible = true
	getItemStats("HEALTH")

func _on_minesButton_pressed():
	currObj = 'Mine'
	isClicked = true
	$clickContainer.visible = false
	$encapItemContainer.visible = true
	getItemStats("Weapon")

func _on_grenadeButton_pressed():
	currObj = 'Grenade'
	isClicked = true
	$clickContainer.visible = false
	$encapItemContainer.visible = true
	getItemStats("Weapon")
