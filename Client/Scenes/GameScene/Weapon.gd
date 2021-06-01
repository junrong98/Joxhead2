extends Node2D

signal weapon_fired(bullet, location, direction)

export (PackedScene) var Bullet

onready var gun_end = $EndOfGun
onready var gun_direction = $GunDirection
onready var attack_cooldown = $CoolDown
onready var animation_play = $AnimationPlayer

# Shoot function with cooldown timer and muzzle flash animation.
# Shoot function includes calling the instance of bullet and adjust the
# direction the bullet will fly to.
func shoot():
	if attack_cooldown.is_stopped() and Bullet != null:
		var bullet_instance = Bullet.instance()
		var shoot_direction = gun_direction.global_position - gun_end.global_position
		emit_signal("weapon_fired", bullet_instance, gun_end.global_position, shoot_direction)
		attack_cooldown.start()
		animation_play.play("muzzle_flash")

	
