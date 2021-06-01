extends Area2D
class_name DemonFireBall

export (int) var speed = 4

onready var kill_timer = $ShootTimer
var move := Vector2.ZERO
var look_vec = Vector2.ZERO
var player = null

func _ready():
	kill_timer.start()
	look_vec = player.position - global_position

func _process(delta):
	move = Vector2.ZERO
	
	move = move.move_toward(look_vec, delta)
	move = move.normalized() * speed
	position += move
	
func _on_ShootTimer_timeout():
	queue_free()

# When the fireball hits the player, only players will take damage
func _on_DemonFireBall_body_entered(body):
	if body.is_in_group("Players"):
		body.demon_fireball()
		queue_free()
