extends KinematicBody2D

class_name Player

signal fired_bullet(bullet, position, direction)

export (int) var speed = 100

onready var weapon = $PlayerSprite/Weapon
onready var health_stat = $HealthBar
onready var player_sprite = $PlayerSprite

var gameoverscreen = preload("res://Scenes/GameScene/GameOverScreen.tscn")
var screensize

func _ready():
	weapon.connect("weapon_fired", self, "shoot")
	screensize = get_viewport_rect().size

#Player movement. Movement are clamp within the screen size so that player
# will not be out of bound
func _physics_process(delta) -> void:
	var movement_direction := Vector2.ZERO;
	if Input.is_action_pressed("up_W") :
		movement_direction.y = -1

	if Input.is_action_pressed("down_S") :
		movement_direction.y = 1

	if Input.is_action_pressed("left_A") :
		movement_direction.x = -1

	if Input.is_action_pressed("right_D") :
		movement_direction.x = 1
	
	movement_direction = movement_direction.normalized();
	position += movement_direction * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
	move_and_slide(movement_direction * speed);
	player_sprite.look_at(get_global_mouse_position())
	

# When the client press left mouse button
func _unhandled_input(event):
	if event.is_action_released("shoot"):
		weapon.shoot()

# shoot function implementation
func shoot(bullet_instance, location: Vector2, direction: Vector2):
	emit_signal("fired_bullet", bullet_instance, location, direction)

# function when the player got attacked by zombie
func zombie_attack():
	health_stat.health_deducted(10)
	if health_stat.players_health <= 0:
		player_lost()
		

# function when the player got attacked by demon fireball
func demon_fireball():
	health_stat.health_deducted(20)
	if health_stat.players_health <= 0:
		player_lost()

# Show gameover menu when the player dies.
func player_lost():
	var game_over = gameoverscreen.instance()
	add_child(game_over)
	get_tree().paused = true
	
	# Check if player achieve highscore
	var newScore = Global.game_highscore

	if newScore > Global.highscore:
		Global.updateHighScore = true
		Global.highscore = newScore
	
