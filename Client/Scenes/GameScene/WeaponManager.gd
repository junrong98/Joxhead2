extends Node2D

signal fired_bullet(bullet, position, direction)

onready var Basic = $Basic
onready var AK47 = $AK47
onready var Uzi = $Uzi
onready var SPAS12 = $SPAS12
onready var weapon_name = get_parent().get_parent().get_node("weapon_GUI/Weapon_name_Label")
onready var weapon_ammo = get_parent().get_parent().get_node("weapon_GUI/Weapon_ammo_Label")

var num_ammo
var invStartPos = 0
var curr_weapon = Global.invArr[invStartPos]
onready var currWeapon = get_node(curr_weapon)
var previousWeapon
var invData = Global.gamedata
var currPlayerInv = []


# Called when the node enters the scene tree for the first time.
func _ready():
	currWeapon.connect("weapon_fired", self, "shoot")
	currWeapon.connect("weapon_ammo", self, "set_current_ammo")
	currWeapon.visible = true
	
	for weapon in Global.gamedata:
		if weapon != "Credit":
			if Global.gamedata[weapon]["Unlocked"]:
				currPlayerInv.push_front(weapon)
	
	Basic_stat()
	AK_47_stat()
	Uzi_stat()
	SPAS12_stat()
	weapon_name.text = str(curr_weapon)

# To ensure that the ammo text will be updated in the UI
func set_current_ammo(new_ammo):
	weapon_ammo.text = str(new_ammo)

# shoot function implementation
func shoot(bullet_instance, location: Vector2, direction: Vector2):
	emit_signal("fired_bullet", bullet_instance, location, direction)

# When the client press left mouse button
func _unhandled_input(event):
	if event.is_action_released("shoot"):
		currWeapon.shoot()
	if event.is_action_pressed("next_weapon"):
		change_next_weapon()
	if event.is_action_pressed("previous_weapon"):
		change_previous_weapon()

# functions to add ammo when the players take the ammo
func add_ammo_curr_weapon(ammo):
	currWeapon.num_ammo += ammo

# Change next weapons
func change_next_weapon():
	if invStartPos == currPlayerInv.size() - 1:
		invStartPos = 0
	else:
		invStartPos += 1
	curr_weapon = currPlayerInv[invStartPos]
	previousWeapon = currWeapon
	previousWeapon.visible = false
	currWeapon = get_node(curr_weapon)
	weapon_name.text = str(curr_weapon)
	currWeapon.visible = true
	currWeapon.connect("weapon_fired", self, "shoot")
	set_current_ammo(currWeapon.num_ammo)
	if not currWeapon.is_connected("weapon_ammo", self, "set_current_ammo"):
		currWeapon.connect("weapon_ammo", self, "set_current_ammo")

# Change previous weapon
func change_previous_weapon():
	if invStartPos == 0:
		invStartPos = currPlayerInv.size() - 1
	else:
		invStartPos -= 1
	curr_weapon = currPlayerInv[invStartPos]
	previousWeapon = currWeapon
	previousWeapon.visible = false
	currWeapon = get_node(curr_weapon)
	weapon_name.text = str(curr_weapon)
	currWeapon.visible = true
	currWeapon.connect("weapon_fired", self, "shoot")
	set_current_ammo(currWeapon.num_ammo)
	if not currWeapon.is_connected("weapon_ammo", self, "set_current_ammo"):
		currWeapon.connect("weapon_ammo", self, "set_current_ammo")

# Below(from basic_stat to SPAS12_stat are stats about each weapons, includes
# ammo, weapon damage and range
func Basic_stat():
	Basic.num_ammo = invData["Basic"]["Ammo"]
	Basic.weapon_dmg = invData["Basic"]["Dmg"]
	Basic.weapon_range = invData["Basic"]["Range"]

func AK_47_stat():
	AK47.num_ammo = invData["AK47"]["Ammo"]
	AK47.weapon_dmg = invData["AK47"]["Dmg"]
	AK47.weapon_range = invData["AK47"]["Range"]

func Uzi_stat():
	Uzi.num_ammo = invData["Uzi"]["Ammo"]
	Uzi.weapon_dmg = invData["Uzi"]["Dmg"]
	Uzi.weapon_range = invData["Uzi"]["Range"]

func SPAS12_stat():
	SPAS12.num_ammo = invData["SPAS12"]["Ammo"]
	SPAS12.weapon_dmg = invData["SPAS12"]["Dmg"]
	SPAS12.weapon_range = invData["SPAS12"]["Range"]
