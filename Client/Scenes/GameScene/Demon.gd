extends KinematicBody2D

export var animations = []
export (int) var attackDistance = 150

onready var player = get_node("/root/World/Player")
onready var fire_ball = preload("res://Scenes/GameScene/DemonFireBall.tscn")
onready var gun_end = $EndOfGun
onready var gun_direction = $GunDirection

var health = 150
var speed = 40
var isAttack = false
var blood_particles = preload("res://Scenes/GameScene/BloodParticles.tscn")

func _ready() -> void:
	pass

# when demon got hit by bullet. Whn the demon is killed, it will add 5 points
# to the highscores and disappear
func handle_hit():
	health -= 20
	var blood_particle_instance = instance_blood_particles()
	blood_particle_instance.rotation = global_position.angle_to_point(player.global_position)
	if health <= 0:
		Global.game_highscore += 5 
		queue_free()

# Movement of the demon
func _physics_process(delta):
	var move = Vector2.ZERO
	move = (player.position - position).normalized()
	demon_movement()
	move_and_slide(move * speed)
		
# Changing the animation of the Demon Sprite
# 0 -> Walk animation
# 1 -> Attack animation	
func play_demon_ani(aniIndex:int):
	$DemonSprite.animation = animations[aniIndex]

# function about demon movement. If the demon is close the the player, it will
# start attacking the players with animation. 
func demon_movement():
	var distance = player.position.distance_to(position)
	var dir = player.position - position
	if distance > attackDistance:
		play_demon_ani(0)
		self.rotation = dir.angle()
	elif !isAttack:
		attack_player()

# When the demon attack player. Display of attack animation and to prevent
# the Demon to continuously attacking the player.
func attack_player():
	var dir = player.position - position
	isAttack = true
	play_demon_ani(1)
	fire()
	self.rotation = dir.angle()
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
