extends Node2D

var barrel_health = 1
var dmg = 60
onready var AOEdmg = $AOEAttack
onready var barrel_base = load("res://Sprites/BombItem/explodedbarrel.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy_object(dmg):
	barrel_health -= dmg
	if barrel_health < 0:
		AOEAttack()
		$BarrelSprite.set_texture(barrel_base)

func bomb_hit(dmg):
	destroy_object(dmg)

func AOEAttack():
	var targets = AOEdmg.get_overlapping_bodies()
	$AOEAttack/ExplosionSprite.play()
	for target in targets:
		target.bomb_hit(dmg)

func _on_BarrelArea_body_exited(body):
	$BarrelStaticBody.set_collision_mask_bit(0,true)
	$BarrelStaticBody.set_collision_layer_bit(0,true)
	$BarrelStaticBody.set_collision_mask_bit(2,true)
	$BarrelStaticBody.set_collision_layer_bit(2,true)


func _on_ExplosionSprite_animation_finished():
	queue_free()
