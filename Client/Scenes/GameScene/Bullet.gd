extends Area2D
class_name Bullet

export (int) var speed = 3

onready var kill_timer = $ShootTimer
var direction := Vector2.ZERO

# Starting of the Shoot timer timer so that the bullet will dissapear
func _ready():
	kill_timer.start()

func _process(delta):
	if direction != Vector2.ZERO:
		var velocity = speed * direction
		global_position += velocity

# Direction whre the bullet going to fly
func set_direction(direction):
	self.direction = direction
	rotation += direction.angle()

# Bullet will be disappear after certain timing
func _on_ShootTimer_timeout():
	queue_free()

# Only when the bullet enter the enemy(zombies & demon) body, it will deduct HP 
# from the enemy.
func _on_Bullet_body_entered(body):
	if body.is_in_group("Enemy"):
		body.handle_hit()
		queue_free()
	else:
		queue_free()
