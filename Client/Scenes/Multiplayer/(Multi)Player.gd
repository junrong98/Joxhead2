extends KinematicBody2D

export (int) var speed = 100

var motion = Vector2.ZERO
var screensize
var can_throw = true

onready var player_label = $Player_name_Label
onready var camera = $Camera2D
onready var player_sprite = $PlayerSprite
onready var weapon_manager = $PlayerSprite/WeaponManager
onready var bullet_manager = $BulletManager
onready var health_stat = $HealthBar
onready var collision = $CollisionShape2D
onready var grenade_num_label = $ItemGUI/GrenadePanel/GreandeLabel
onready var landmine_num_label = $ItemGUI/LandminePanel/LandmineLabel
onready var fakewall_num_label = $ItemGUI/FakewallPanel/FakewallLabel
onready var barrel_num_label = $ItemGUI/BarrelPanel/BarrelLabel
onready var players = get_tree().get_root().find_node("Players", true, false)
onready var dead_players = get_tree().get_root().find_node("Dead_player", true, false)
onready var world = get_tree().root.get_node("(Multi)World")

var gameoverscreen = preload("res://Scenes/GameScene/GameOverScreen.tscn")
onready var grenade_bomb = preload("res://Scenes/GameScene/BombItems/Grenade.tscn")
onready var landmine_bomb = preload("res://Scenes/GameScene/BombItems/Landmine.tscn")
onready var fake_wall = preload("res://Scenes/GameScene/BombItems/Fakewall.tscn")
onready var barrel_bomb = preload("res://Scenes/GameScene/BombItems/Barrel.tscn")
onready var game_over = preload("res://Scenes/Multiplayer/GameOverGui.tscn")
onready var pause_scence = preload("res://Scenes/Multiplayer/(Multi)IngamePauseMenu.tscn")
onready var turn_axis = $PlayerSprite/TurnAxis
onready var castpoint = $PlayerSprite/TurnAxis/CastPoint
onready var castbarricade = $PlayerSprite/CastBarricade
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')

var invData = Global.gamedata
var num_grenade = invData["Grenade"]["Ammo"] 
var num_landmine = invData["Mine"]["Ammo"]
var num_fakewall = invData["Fake_Wall"]["Ammo"]
var num_barrel = invData["Barrel"]["Ammo"]


func _ready():
	screensize = get_viewport_rect().size
	weapon_manager.connect("fired_bullet", bullet_manager, "handle_bullet_spwaned")
	player_label.set_as_toplevel(true)
	grenade_num_label.text = str(num_grenade)
	landmine_num_label.text = str(num_landmine)
	fakewall_num_label.text = str(num_fakewall)
	barrel_num_label.text = str(num_barrel)

func _physics_process(delta):
	if is_network_master():
		camera.current = true
		player_label.rect_position = Vector2(position.x - 10, position.y - 66)
		var x_input = int(Input.is_action_pressed("right_D")) - int(Input.is_action_pressed("left_A"))
		var y_input = int(Input.is_action_pressed("down_S")) - int(Input.is_action_pressed("up_W"))
			
		motion = Vector2(x_input, y_input).normalized()
			
		move_and_slide(motion * speed)
		# clamp method so that players will not move out of the screen
		position.x = clamp(position.x, 0, screensize.x)
		position.y = clamp(position.y, 0, screensize.y)
		player_sprite.look_at(get_global_mouse_position())
		
		rpc_unreliable_id(1, "update_player", global_transform)
		rpc_unreliable_id(1, "update_player_sprite_dir", player_sprite.global_rotation)

remote func update_remote_player(transform):
	if not is_network_master():
		global_transform = transform
		player_label.rect_position = Vector2(position.x - 10, position.y - 66)

remote func update_remote_player_dir(dir):
	if not is_network_master():
		player_sprite.rotation = dir

func _unhandled_input(event):
	if is_network_master():
		if event.is_action_pressed("throw_item") and can_throw and num_grenade != 0:
			rpc_id(1, "throw_grenades", num_grenade - 1, Global.uuid)
		if event.is_action_pressed("plant_landmine") and can_throw and num_landmine != 0:
			rpc_id(1, "plant_landmine", num_landmine - 1, Global.uuid)
		if event.is_action_pressed("place_fakewall") and can_throw and num_fakewall != 0:
			rpc_id(1, "put_fakewall", num_fakewall - 1, Global.uuid)
		if event.is_action_pressed("place_barrel") and can_throw and num_barrel != 0:
			rpc_id(1, "put_barrel", num_barrel - 1, Global.uuid)
		if event.is_action_pressed("Pause_game"):
			show_pause_menu()
			
func _process(delta):
	get_node("ItemGUI/GrenadePanel/GreandeLabel").set_text(str(invData["Grenade"]["Ammo"]))
	get_node("ItemGUI/LandminePanel/LandmineLabel").set_text(str(invData["Mine"]["Ammo"]))
	get_node("ItemGUI/FakewallPanel/FakewallLabel").set_text(str(invData["Fake_Wall"]["Ammo"]))
	get_node("ItemGUI/BarrelPanel/BarrelLabel").set_text(str(invData["Barrel"]["Ammo"]))

remote func throw_grenade(grenade_id):
	can_throw = false
	turn_axis.rotation = get_angle_to(get_global_mouse_position())
	var grenade = grenade_bomb.instance()
	grenade.name = grenade_id
	grenade.position = castpoint.get_global_position()
	grenade.rotation = get_angle_to(get_global_mouse_position())
	grenade.throw_at_mouse(grenade.position)
	get_parent().add_child(grenade)
	
	yield(get_tree().create_timer(0.4), "timeout")
	can_throw = true

remote func grenade_update(num, uuid):
	num_grenade = num
	invData["Grenade"]["Ammo"] = num_grenade
	invCollection.update("" + uuid, {"Grenade" : invData["Grenade"]})

remote func plant_landmines(landmine_id):
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var landmine = landmine_bomb.instance()
		landmine.name = landmine_id
		landmine.position = get_global_position()
		world.add_child(landmine)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

remote func landmine_update(num, uuid):
	num_landmine = num
	invData["Mine"]["Ammo"] = num_landmine
	invCollection.update("" + uuid, {"Mine" : invData["Mine"]})

remote func put_fakewalls(fakewall_id):
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var fakewall = fake_wall.instance()
		fakewall.name = fakewall_id
		fakewall.position = $PlayerSprite/CastBarricade.get_global_position()
		get_parent().add_child(fakewall)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

remote func fakewall_update(num, uuid):
	num_fakewall = num
	invData["Fake_Wall"]["Ammo"] = num_fakewall
	invCollection.update("" + uuid, {"Fake_Wall" : invData["Fake_Wall"]})

remote func put_barrels(barrel_id):
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var barrel = barrel_bomb.instance()
		barrel.name = barrel_id
		barrel.position = $PlayerSprite/CastBarricade.get_global_position()
		get_parent().add_child(barrel)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

remote func barrel_update(num, uuid):
	num_barrel = num
	invData["Barrel"]["Ammo"] = num_barrel
	invCollection.update("" + uuid, {"Barrel" : invData["Barrel"]})


func zombie_attack(zombie_dmg):
	$HealthBar.health_deducted(zombie_dmg)
	if $HealthBar.players_health <= 0:
		rpc_id(1, "die")

func bomb_hit(dmg):
	$HealthBar.health_deducted(dmg)
	if $HealthBar.players_health <= 0:
		rpc_id(1, "die")

func demon_fireball(fireball_dmg):
	$HealthBar.health_deducted(fireball_dmg)
	if $HealthBar.players_health <= 0:
		rpc_id(1, "die")
		

sync func player_died():
	set_physics_process(false)
	collision.disabled = true
	hide()
	player_label.hide()
	rpc_id(1, "remove_player", self.name)
	players.remove_child(self)
	dead_players.add_child(self)
	world.show_gameover()

func set_player_name(username):
	get_node("Player_name_Label").set_text(username)

func add_health(recover_amt):
	$HealthBar.health_added(recover_amt)

# function to add the ammo when get the ammopack
func add_ammo(ammo_amt):
	weapon_manager.add_ammo_curr_weapon(ammo_amt)

func add_coins():
	Global.coin_earn += 15

func show_pause_menu():
	var pause_instance = pause_scence.instance()
	add_child(pause_instance)

func player_exited():
	if players.get_children().size() == 1:
		rpc_id(1, "die")
		Server.end_game()
	rpc_id(1, "die")
