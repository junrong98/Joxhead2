extends RigidBody2D

var dmg = 60
var dmg_delay_time = 2
var speed = 300
onready var AOEdmg = $AOEAttack
onready var bomb_time = $Bomb_Timer


func _ready():
	#apply_impulse(Vector2(), Vector2(300, 0).rotated(rotation))
	pass

func throw_at_mouse(start_pos):
	var target_pos = get_global_mouse_position()
	self.global_position = start_pos
	self.look_at(target_pos)
	var direction = (target_pos - start_pos).normalized()
	self.linear_velocity = direction * speed

func AOEAttack():
	var targets = AOEdmg.get_overlapping_bodies()
	$AOEAttack/ExplosionSprite.play()
	for target in targets:
		target.bomb_hit(dmg)

func _on_ExplosionSprite_animation_finished():
	self.queue_free()

func _on_Bomb_Timer_timeout():
	AOEAttack()
	$GrenadeSprite.visible = false
