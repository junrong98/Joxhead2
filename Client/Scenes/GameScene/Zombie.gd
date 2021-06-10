extends KinematicBody2D

export var animations = []
export (int) var attackDistance = 60


onready var players = get_node("/root/World/Player")
onready var nav_2d = get_node("/root/World/Navigation2D")

#TO BE EDIT IN FUTURE
var path = PoolVector2Array() setget set_path

var speed = 40.0
var isAttack = false
var health_stat = 60
var blood_particles = preload("res://Scenes/GameScene/BloodParticles.tscn")
var med_kit_scene = preload("res://Scenes/GameScene/DropItems/MedKitItem.tscn")
var ammo_pack_scence = preload("res://Scenes/GameScene/DropItems/AmmoPackItem.tscn")
var coins_scence = preload("res://Scenes/GameScene/DropItems/CoinsItem.tscn")

# randomised() function to truely radomised the drop loots rate. Set_process for pathfinding algo
func _ready() -> void:
	set_process(false)
	randomize()

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
	var blood_particle_instance = instance_blood_particles()
	blood_particle_instance.rotation = global_position.angle_to_point(players.global_position)
	if health_stat <= 0:
		Global.game_highscore += 1
		death_drop_loots()
		queue_free()

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
		attack_player()

# When the zombie attak player
func attack_player():
	var dir = players.position - position
	isAttack = true
	play_zombie_ani(1)
	self.rotation = dir.angle()
	yield($ZombieSprite,"animation_finished")
	players.zombie_attack()
	isAttack = false

# Instance of blood particles
func instance_blood_particles():
	var blood_instance = blood_particles.instance()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	return blood_instance

# After death, the loots will drop with randomized chances.
func death_drop_loots():
	var i = rand_range(1,11)
	if i >= 1 and i <= 2:
		var medkit = med_kit_scene.instance()
		medkit.global_position = global_position
		get_tree().get_root().add_child(medkit)
	elif i > 2 and i <= 3.5:
		var ammoPack = ammo_pack_scence.instance()
		ammoPack.global_position = global_position
		get_tree().get_root().add_child(ammoPack)
	elif i > 3.5 and i <= 4.5:
		var coins = coins_scence.instance()
		coins.global_position = global_position
		get_tree().get_root().add_child(coins)
