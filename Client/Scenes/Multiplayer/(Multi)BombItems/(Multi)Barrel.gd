extends Node2D

var barrel_health = 1
var dmg = 60
onready var AOEdmg = $AOEAttack
onready var barrel_base = load("res://Sprites/BombItem/explodedbarrel.png")

func destroy_object(dmg):
	barrel_health -= dmg
	rpc_id(1, "barrel_explode", barrel_health)

func bomb_hit(dmg):
	destroy_object(dmg)

func AOEAttack():
	var targets = AOEdmg.get_overlapping_bodies()
	print(targets)
	$AOEAttack/ExplosionSprite.play()
	for target in targets:
		if target.is_in_group("BarricadeObject"):
			target.bomb_hit(dmg)
		target.bomb_hit(dmg)

func _on_BarrelArea_body_exited(body):
	$BarrelStaticBody.set_collision_mask_bit(0,true)
	$BarrelStaticBody.set_collision_layer_bit(0,true)
	$BarrelStaticBody.set_collision_mask_bit(2,true)
	$BarrelStaticBody.set_collision_layer_bit(2,true)

sync func barrel_exploded(health):
	if health < 0:
		AOEAttack()
		$BarrelSprite.set_texture(barrel_base)

func _on_ExplosionSprite_animation_finished():
	rpc_id(1, "remove_barrel")

sync func barrel_removed():
	queue_free()
