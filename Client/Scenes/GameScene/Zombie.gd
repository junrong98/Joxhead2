extends KinematicBody2D

export var animations = []
export (int) var attackDistance = 50

onready var player = get_node("/root/World/Player")

var speed = 40
var isAttack = false
var health_stat = 100
var blood_particles = preload("res://Scenes/GameScene/BloodParticles.tscn")

func _ready() -> void:
	pass

# when zombie got hit by bullet
func handle_hit():
	health_stat -= 100
	var blood_particle_instance = instance_blood_particles()
	blood_particle_instance.rotation = global_position.angle_to_point(player.global_position)
	if health_stat <= 0:
		Global.game_highscore += 1
		queue_free()

# Movement of the zombie
func _physics_process(delta):
	var move = Vector2.ZERO
	move = (player.position - position).normalized()
	zomebie_movement()
	move_and_slide(move * speed)
	
	
# Chaning the animation of the Zombie Sprite
# 0 -> Walk animation
# 1 -> Attack animation	
func play_zombie_ani(aniIndex:int):
	$ZombieSprite.animation = animations[aniIndex]

# function about zombie movement
func zomebie_movement():
	var distance = player.position.distance_to(position)
	var dir = player.position - position
	if distance > attackDistance:
		play_zombie_ani(0)
		self.rotation = dir.angle()
	elif !isAttack:
		attack_player()

# When the zombie attak player
func attack_player():
	var dir = player.position - position
	isAttack = true
	play_zombie_ani(1)
	self.rotation = dir.angle()
	yield($ZombieSprite,"animation_finished")
	player.zombie_attack()
	isAttack = false

# Instance of blood particles
func instance_blood_particles():
	var blood_instance = blood_particles.instance()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	return blood_instance
