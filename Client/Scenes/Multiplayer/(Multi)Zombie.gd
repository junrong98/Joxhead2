extends KinematicBody2D

export var animations = []
export (int) var attackDistance = 50

var players
var nav_2d 
var possible_players

const MAXSPEED = 80
const ACCELERATION = 300

var motion = Vector2.ZERO

onready var multi_player = get_tree().get_root().find_node("Players", true, false)
onready var world = get_tree().root.get_node("(Multi)World")
onready var zombie_parent = get_tree().get_root().find_node("Zombies", true, false)

#TO BE EDIT IN FUTURE
var path = PoolVector2Array() setget set_path

var speed = 40.0
var isAttack = false
var health_stat = 60
var zombie_dmg = 10
var blood_particles = preload("res://Scenes/GameScene/BloodParticles.tscn")


# randomised() function to truely radomised the drop loots rate. Set_process for pathfinding algo
func _ready():
	possible_players = multi_player.get_children()
	players = possible_players[0]
	rpc_id(1, "select_target")
	for nav_group_node in get_tree().get_nodes_in_group("LevelNavigation"):
		nav_2d = nav_group_node;
		break;
	set_process(false)
	randomize()

remote func select_player_target(idx):
	players = possible_players[idx]

# Movement of the demon. move_along_path() and set_path() is part of the pathfinding algo
# for the monster to find the players and avoid the wall. Note: the floor in tilemap(In Map scence) must 
# have navigation highlighted then it can work
func _physics_process(delta):
	var new_path = nav_2d.get_simple_path(self.global_position, players.global_position, false)
	path = new_path 
	var move_distance = speed * delta
	zomebie_movement()
	move_along_path(move_distance)

func move_along_path(distance):
	var start_position = position
	for i in range(path.size()):
		var distance_to_next = start_position.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = start_position.linear_interpolate(path[0], distance/distance_to_next)
			move_and_slide(Vector2.ZERO)
			break
		distance -= distance_to_next
		start_position = path[0]
		path.remove(0)

func set_path(value):
	path = value
	if value.size() == 0:
		return
	set_process(true)

# when zombie got hit by bullet
func handle_hit(dmg_amt):
	health_stat -= dmg_amt
	rpc_id(1, "zombie_get_hit", get_name(), dmg_amt)
	#var blood_particle_instance = instance_blood_particles()
	rpc_id(1, "blood", global_position)
	if health_stat <= 0:
		world.add_score(1)
		death_drop_loots()
		queue_free()

func bomb_hit(dmg):
	health_stat -= dmg
	rpc_id(1, "zombie_get_hit", get_name(), dmg)
	#var blood_particle_instance = instance_blood_particles()
	rpc_id(1, "blood", global_position)
	if health_stat <= 0:
		world.add_score(1)
		death_drop_loots()
		queue_free()

sync func remove_zombie():
	zombie_parent.remove_child(self)

# Changing the animation of the Zombie Sprite
# 0 -> Walk animation
# 1 -> Attack animation	
func play_zombie_ani(aniIndex:int):
	$ZombieSprite.animation = animations[aniIndex]

# function about zombie movement
func zomebie_movement():
	var distance = players.position.distance_to(position)
	var dir = players.position - position
	if distance > attackDistance:
		play_zombie_ani(0)
		self.rotation = dir.angle()
	elif !isAttack:
		#pass
		attack_player()

# When the zombie attak player
func attack_player():
	var dir = players.position - position
	isAttack = true
	play_zombie_ani(1)
	self.rotation = dir.angle()
	yield($ZombieSprite,"animation_finished")
	players.zombie_attack(zombie_dmg)
	isAttack = false

remote func spawn_blood(pos):
	var blood_instance = blood_particles.instance()
	blood_instance.global_position = global_position
	blood_instance.rotation = global_position.angle_to_point(players.global_position)
	world.add_child(blood_instance)

# After death, the loots will drop with randomized chances.
func death_drop_loots():
	var i = rand_range(1,11)
	if i >= 1 and i <= 2:
		world.spawn_medkit(global_position)
	elif i > 2 and i <= 3.5:
		world.spawn_ammopack(global_position)
	elif i > 3.5 and i <= 4.5:
		world.spawn_coins(global_position)

# To change target
func _on_DetectPlayer_body_entered(body):
	if body.is_in_group("Players"):
		rpc_id(1, "select_target")
