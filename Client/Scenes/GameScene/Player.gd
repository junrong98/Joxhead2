extends KinematicBody2D

export (int) var speed = 100

signal grenade_num_update(grenade_amt)
signal landmine_num_update(landmine_amt)
signal fakewall_num_update(fakewall_amt)
signal barrel_num_update(barrel_amt)

onready var weapon = $PlayerSprite/WeaponManager
onready var health_stat = $HealthBar
onready var player_sprite = $PlayerSprite
onready var turn_axis = $PlayerSprite/TurnAxis
onready var castpoint = $PlayerSprite/TurnAxis/CastPoint
onready var castbarricade = $PlayerSprite/CastBarricade
onready var grenade_bomb = preload("res://Scenes/GameScene/BombItems/Grenade.tscn")
onready var landmine_bomb = preload("res://Scenes/GameScene/BombItems/Landmine.tscn")
onready var fake_wall = preload("res://Scenes/GameScene/BombItems/Fakewall.tscn")
onready var barrel_bomb = preload("res://Scenes/GameScene/BombItems/Barrel.tscn")
onready var invCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')

var gameoverscreen = preload("res://Scenes/GameScene/GameOverScreen.tscn")
var pausescreen = preload("res://Scenes/GameScene/IngamePauseMenu.tscn")
var screensize
var coins_earned = 0
var can_throw = true
var invData = Global.gamedata
var num_grenade = invData["Grenade"]["Ammo"]
var num_landmine = invData["Mine"]["Ammo"]
var num_fakewall = invData["Fake_Wall"]["Ammo"]
var num_barrel = invData["Barrel"]["Ammo"]

# Preload diconnect scene
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

func _ready():
	screensize = get_viewport_rect().size
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")

func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)
	get_tree().paused = true

#Player movement.
func _physics_process(delta) -> void:
	var movement_direction := Vector2.ZERO;
	if Input.is_action_pressed("up_W") :
		movement_direction.y = -1

	if Input.is_action_pressed("down_S") :
		movement_direction.y = 1

	if Input.is_action_pressed("left_A") :
		movement_direction.x = -1

	if Input.is_action_pressed("right_D") :
		movement_direction.x = 1
	
	movement_direction = movement_direction.normalized();
	position += movement_direction * delta
	
	# clamp method so that players will not move out of the screen
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
	
	move_and_slide(movement_direction * speed);
	player_sprite.look_at(get_global_mouse_position())

# for throwing projectile. Edit in future if need to
func _process(delta):
	if Input.is_action_pressed("throw_item") and can_throw and num_grenade != 0:
		throw_grenade()
	if Input.is_action_pressed("plant_landmine") and can_throw and num_landmine != 0:
		plant_landmine()
	if Input.is_action_pressed("place_fakewall") and can_throw and num_fakewall != 0:
		put_fakewalls()
	if Input.is_action_pressed("place_barrel") and can_throw and num_barrel != 0:
		put_barrels()
	if Input.is_action_pressed("Pause_game"):
		pause_game()

func grenade_update(num):
	num_grenade = num
	emit_signal("grenade_num_update", num_grenade)
	invData["Grenade"]["Ammo"] = num_grenade
	invCollection.update("" + Global.uuid, {"Grenade" : invData["Grenade"]})

func landmine_update(num):
	num_landmine = num
	emit_signal("landmine_num_update", num_landmine)
	invData["Mine"]["Ammo"] = num_landmine
	invCollection.update("" + Global.uuid, {"Mine" : invData["Mine"]})
	

func fakewall_update(num):
	num_fakewall = num
	emit_signal("fakewall_num_update", num_fakewall)
	invData["Fake_Wall"]["Ammo"] = num_fakewall
	invCollection.update("" + Global.uuid, {"Fake_Wall" : invData["Fake_Wall"]})

func barrel_update(num):
	num_barrel = num
	emit_signal("barrel_num_update", num_barrel)
	invData["Barrel"]["Ammo"] = num_barrel
	invCollection.update("" + Global.uuid, {"Barrel" : invData["Barrel"]})

func throw_grenade():
	can_throw = false
	turn_axis.rotation = get_angle_to(get_global_mouse_position())
	var grenade = grenade_bomb.instance()
	grenade.position = castpoint.get_global_position()
	grenade.rotation = get_angle_to(get_global_mouse_position())
	get_parent().add_child(grenade)
	grenade_update(num_grenade - 1)
	yield(get_tree().create_timer(0.4), "timeout")
	can_throw = true

func plant_landmine():
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var landmine = landmine_bomb.instance()
		landmine.position = get_global_position()
		get_parent().add_child(landmine)
		landmine_update(num_landmine - 1)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

func put_fakewalls():
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var fakewall = fake_wall.instance()
		fakewall.position = $PlayerSprite/CastBarricade.get_global_position()
		get_parent().add_child(fakewall)
		fakewall_update(num_fakewall - 1)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

func put_barrels():
	can_throw = false
	if $PlayerSprite/CastBarricade/CastArea.get_overlapping_areas().empty():
		var barrel = barrel_bomb.instance()
		barrel.position = $PlayerSprite/CastBarricade.get_global_position()
		get_parent().add_child(barrel)
		barrel_update(num_barrel - 1)
		yield(get_tree().create_timer(0.4), "timeout")
		can_throw = true
	can_throw = true

# function when the player got attacked by zombie
func zombie_attack(zombie_dmg):
	health_stat.health_deducted(zombie_dmg)
	if health_stat.players_health <= 0:
		player_lost()

func bomb_hit(dmg):
	health_stat.health_deducted(dmg)
	if health_stat.players_health <= 0:
		player_lost()

# function when the player got attacked by demon fireball
func demon_fireball(fireball_dmg):
	health_stat.health_deducted(fireball_dmg)
	if health_stat.players_health <= 0:
		player_lost()

# Show gameover menu when the player dies.
func player_lost():
	var game_over = gameoverscreen.instance()
	add_child(game_over)
	get_tree().paused = true
	
	# Check if player achieve highscore
	var newScore = Global.game_highscore
	
	if newScore > Global.highscore:
		Global.updateHighScore = true
		Global.highscore = newScore

# function to add players health when get medkit
func add_health(recover_amt):
	health_stat.health_added(recover_amt)

# function to add the ammo when get the ammopack
func add_ammo(ammo_amt):
	weapon.add_ammo_curr_weapon(ammo_amt)

func add_coins():
	coins_earned += 15

func pause_game():
	var pause_game = pausescreen.instance()
	add_child(pause_game)
	get_tree().paused = true
	
	# Check if player achieve highscore
	var newScore = Global.game_highscore
	
	if newScore > Global.highscore:
		Global.updateHighScore = true
		Global.highscore = newScore
