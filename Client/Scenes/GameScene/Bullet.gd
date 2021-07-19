extends Area2D
class_name Bullet

export (float) var speed = 15

onready var kill_timer = $ShootTimer
var direction := Vector2.ZERO
var bullet_dmg
var range_time

# Starting of the Shoot timer timer so that the bullet will dissapear
func _ready():
	pass

#func _physics_process(delta):
#	position += transform.x * speed * delta

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
		body.handle_hit(bullet_dmg)
		queue_free()
	elif body.is_in_group("BarricadeObject"):
		body.destroy_object(bullet_dmg)
		queue_free()
	else:
		queue_free()

func set_weapon_damage(dmg):
	bullet_dmg = dmg

func set_range_time(time):
	$ShootTimer.start(time/20)
