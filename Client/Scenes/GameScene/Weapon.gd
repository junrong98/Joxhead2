extends Node2D

signal weapon_ammo(new_ammo_count)
signal weapon_fired(bullet, location, direction)

export (PackedScene) var Bullet

var num_ammo = 0 setget set_current_ammo
var weapon_range
var weapon_dmg

onready var gun_end = $EndOfGun
onready var gun_direction = $GunDirection
onready var attack_cooldown = $CoolDown
onready var animation_play = $AnimationPlayer

# Shoot function with cooldown timer and muzzle flash animation.
# Shoot function includes calling the instance of bullet and adjust the
# direction the bullet will fly to.
func shoot():
	if attack_cooldown.is_stopped() and Bullet != null and num_ammo != 0:
		var bullet_instance = Bullet.instance()
		var shoot_direction = (gun_end.global_position - global_position).normalized()
		emit_signal("weapon_fired", bullet_instance, gun_end.global_position, shoot_direction)
		bullet_instance.set_weapon_damage(weapon_dmg)
		bullet_instance.set_range_time(weapon_range)
		attack_cooldown.start()
		animation_play.play("muzzle_flash")
		$Firing_sound.play()
		set_current_ammo(num_ammo - 1)
	elif num_ammo == 0:
		$Out_of_ammo_sound.play()

#Update the number of ammo of the weapon
func set_current_ammo(new_ammo: int):
	var actual_ammo = new_ammo
	if actual_ammo != num_ammo:
		num_ammo = actual_ammo
		emit_signal("weapon_ammo", num_ammo)
