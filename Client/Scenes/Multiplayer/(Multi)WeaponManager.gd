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
			if Global.gamedata[weapon]["Type"] == "Weapon" && Global.gamedata[weapon]["Unlocked"]:
				currPlayerInv.push_front(weapon)
	
	Basic_stat()
	AK_47_stat()
	Uzi_stat()
	SPAS12_stat()
	weapon_name.text = str(curr_weapon)

# To ensure that the ammo text will be updated in the UI
func set_current_ammo(new_ammo):
	rpc_id(get_tree().get_rpc_sender_id(), "set_weapon_ammo", new_ammo)
	weapon_ammo.text = str(new_ammo)

# shoot function implementation
func shoot(bullet_instance, location: Vector2, direction: Vector2):
	emit_signal("fired_bullet", bullet_instance, location, direction)

# When the client press left mouse button
func _unhandled_input(event):
	if is_network_master():
		if event.is_action_pressed("shoot"):
			rpc_id(1, "player_bullet")
		if event.is_action_pressed("next_weapon"):
			rpc_id(1,"change_next")
		if event.is_action_pressed("previous_weapon"):
			rpc_id(1,"change_previous")

remotesync func spawn_bullet():
	currWeapon.shoot()

# functions to add ammo when the players take the ammo
func add_ammo_curr_weapon(ammo):
	currWeapon.num_ammo += ammo

# Change next weapons
sync func change_next_weapon():
	if invStartPos == currPlayerInv.size() - 1:
		invStartPos = 0
	else:
		invStartPos += 1
	curr_weapon = currPlayerInv[invStartPos]
	previousWeapon = currWeapon
	previousWeapon.visible = false
	rpc_id(get_tree().get_rpc_sender_id(), "set_weapon", curr_weapon)
	currWeapon = get_node(curr_weapon)
	weapon_name.text = str(curr_weapon)
	currWeapon.visible = true
	currWeapon.connect("weapon_fired", self, "shoot")
	set_current_ammo(currWeapon.num_ammo)
	if not currWeapon.is_connected("weapon_ammo", self, "set_current_ammo"):
		currWeapon.connect("weapon_ammo", self, "set_current_ammo")

remote func update_weapon_text(curr_weapon_name, curr_weapon_texture, previous_weapon):
	if not is_network_master():
		get_parent().get_parent().get_node("weapon_GUI/Weapon_name_Label").set_text(curr_weapon_name)
		var prevWeapon = get_node(previous_weapon)
		prevWeapon.visible = false
		currWeapon = get_node(curr_weapon_texture)
		currWeapon.visible = true
		currWeapon.connect("weapon_fired", self, "shoot")

remote func update_weapon_ammo(weapon_ammo):
	if not is_network_master():
		get_parent().get_parent().get_node("weapon_GUI/Weapon_ammo_Label").set_text(weapon_ammo)

# Change previous weapon
sync func change_previous_weapon():
	if invStartPos == 0:
		invStartPos = currPlayerInv.size() - 1
	else:
		invStartPos -= 1
	curr_weapon = currPlayerInv[invStartPos]
	previousWeapon = currWeapon
	previousWeapon.visible = false
	currWeapon = get_node(curr_weapon)
	weapon_name.text = str(curr_weapon)
	rpc_id(get_tree().get_rpc_sender_id(), "set_weapon", curr_weapon)
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
	rpc_id(get_tree().get_rpc_sender_id(),"AK_47_stats", invData["AK47"]["Range"])
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
