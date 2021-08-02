extends KinematicBody2D

export var animations = []
export (int) var attackDistance = 150

var player
var nav_2d 
onready var fire_ball = preload("res://Scenes/GameScene/DemonFireBall.tscn")
onready var gun_end = $EndOfGun
onready var gun_direction = $GunDirection

var path
var health = 100
var speed = 40
var isAttack = false
var blood_particles = preload("res://Scenes/GameScene/BloodParticles.tscn")
var med_kit_scene = preload("res://Scenes/GameScene/DropItems/MedKitItem.tscn")
var ammo_pack_scence = preload("res://Scenes/GameScene/DropItems/AmmoPackItem.tscn")
var coins_scence = preload("res://Scenes/GameScene/DropItems/CoinsItem.tscn")


# randomised() function to truely radomised the drop loots rate. Set_process for pathfinding algo
func _ready() -> void:
	player = get_parent().get_node("Player")
	nav_2d = get_parent().get_node("Navigation2D")
	#set_process(false)
	randomize()

# Movement of the demon. move_along_path() and set_path() is part of the pathfinding algo
# for the monster to find the players and avoid the wall. Note: the floor in tilemap(In Map scence) must 
# have navigation highlighted then it can work
func _physics_process(delta):
	path = nav_2d.get_simple_path(get_global_position(), player.get_global_position(), false)
	var move_distance = speed * delta
	move_along_path(move_distance)
	demon_movement()


func move_along_path(distance):
	var start_position = get_global_position()
	for i in range(path.size()):
		var distance_to_next = start_position.distance_to(path[0])
		if distance <= distance_to_next:
			var move_rotated = get_angle_to(start_position.linear_interpolate(path[0], distance/distance_to_next))
			var motion = Vector2(speed, 0).rotated(move_rotated)
			move_and_slide(motion)
			break
		distance -= distance_to_next
		start_position = path[0]
		path.remove(0)

# when demon got hit by bullet. Whn the demon is killed, it will add 5 points
# to the highscores and disappear
func handle_hit(dmg_amt):
	health -= dmg_amt
	var blood_particle_instance = instance_blood_particles()
	blood_particle_instance.rotation = global_position.angle_to_point(player.global_position)
	if health <= 0:
		Global.game_highscore += 5
		get_parent().num_of_demon_left -= 1
		death_drop_loots()
		queue_free()

func bomb_hit(dmg):
	health -= dmg
	var blood_particle_instance = instance_blood_particles()
	if health <= 0:
		Global.game_highscore += 1
		get_parent().num_of_demon_left -= 1
		death_drop_loots()
		queue_free()

# Changing the animation of the Demon Sprite
# 0 -> Walk animation
# 1 -> Attack animation	
func play_demon_ani(aniIndex:int):
	$DemonSprite.animation = animations[aniIndex]

# function about demon movement. If the demon is close the the player, it will
# start attacking the players with animation. 
func demon_movement():
	var distance = player.position.distance_to(position)
	if distance > attackDistance:
		play_demon_ani(0)
		$DemonSprite.look_at(player.global_position)
	elif !isAttack:
		attack_player()

# When the demon attack player. Display of attack animation and to prevent
# the Demon to continuously attacking the player.
func attack_player():
	isAttack = true
	play_demon_ani(1)
	fire()
	$DemonSprite.look_at(player.global_position)
	yield($DemonSprite,"animation_finished")
	isAttack = false

# Firing of the Demon fire ball
func fire():
	var demon_fire = fire_ball.instance()
	demon_fire.position = get_global_position()
	demon_fire.player = player
	get_parent().add_child(demon_fire)
	
# Calling the instance of blood particles of the demon
func instance_blood_particles():
	var blood_instance = blood_particles.instance()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	return blood_instance

# After death, the loots will drop with randomized chances.
func death_drop_loots():
	var i = rand_range(1,11)
	if i >= 1 and i <= 2.5:
		var medkit = med_kit_scene.instance()
		medkit.global_position = global_position
		get_tree().get_root().add_child(medkit)
	elif i > 2.5 and i <= 4:
		var ammoPack = ammo_pack_scence.instance()
		ammoPack.global_position = global_position
		get_tree().get_root().add_child(ammoPack)
	elif i > 4 and i <= 5.5:
		var coins = coins_scence.instance()
		coins.global_position = global_position
