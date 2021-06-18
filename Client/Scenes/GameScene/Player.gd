extends KinematicBody2D

class_name Player

export (int) var speed = 100

onready var weapon = $PlayerSprite/WeaponManager
onready var health_stat = $HealthBar
onready var player_sprite = $PlayerSprite
onready var grenade_bomb = preload("res://Scenes/GameScene/BombItems/Grenade.tscn")
onready var landmine_bomb = preload("res://Scenes/GameScene/BombItems/Landmine.tscn")

var gameoverscreen = preload("res://Scenes/GameScene/GameOverScreen.tscn")
var screensize
var coins_earned = 0
var can_throw = true

func _ready():
	screensize = get_viewport_rect().size

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
#func _process(delta):
#	if Input.is_action_pressed("throw_item") and can_throw:
#		throw_grenade()
#	if Input.is_action_pressed("plant_landmine") and can_throw:
#		plant_landmine()
#
#func throw_grenade():
#	can_throw = false
#	get_node("PlayerSprite/TurnAxis").rotation = get_angle_to(get_global_mouse_position())
#	var grenade = grenade_bomb.instance()
#	grenade.position = get_node("PlayerSprite/TurnAxis/CastPoint").get_global_position()
#	grenade.rotation = get_angle_to(get_global_mouse_position())
#	get_parent().add_child(grenade)
#	yield(get_tree().create_timer(0.4), "timeout")
#	can_throw = true
#
#func plant_landmine():
#	can_throw = false
#	var landmine = landmine_bomb.instance()
#	landmine.position = get_global_position()
#	get_parent().add_child(landmine)
#	yield(get_tree().create_timer(0.4), "timeout")
#	can_throw = true

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
