extends Control

onready var bullet_manager = $BulletManager
onready var player: Player = $Player
onready var weapon_manager = $Player/PlayerSprite/WeaponManager
onready var zombie_spawn_timing = $Zombie_spawn_timer
onready var demon_spawn_timing = $Demon_spawn_timer
onready var wave_notification = $GUI/WaveNotificationLabel
onready var wave_noti_timer = $GUI/WaveNotificationLabel/WaveNotification_timer

var zombies = preload("res://Scenes/GameScene/Zombie.tscn")
var demons = preload("res://Scenes/GameScene/Demon.tscn")
var wave_num = 1
var zombie_spawn_number = 1
var demon_spawn_number = 0
var screensize

# Called when the node enters the scene tree for the first time. Spawn waves() function
# to automatically spawn the first wave.
func _ready():
	#For bullets
	weapon_manager.connect("fired_bullet", bullet_manager, "handle_bullet_spwaned")
	screensize = get_viewport_rect().size

# Randomly spawn zombie outside of the screen size area
func zombie_wave():
	for i in range(0, zombie_spawn_number):
		var zombie_position = Vector2(rand_range(-40, screensize.x + 50), rand_range(-50, screensize.y + 50))

		while zombie_position.x < screensize.x and zombie_position.x > -30 and zombie_position.y < screensize.y  and zombie_position.y > -35:
			zombie_position = Vector2(rand_range(-40, screensize.x + 50), rand_range(-50, screensize.y + 50))

		var zombie_instance = zombies.instance()
		add_child(zombie_instance)
		zombie_instance.global_position = zombie_position

# Randomly spawn demon outside of the screen size area
func demon_wave():
	for j in range(0, demon_spawn_number):
		var demon_position = Vector2(rand_range(-40, screensize.x + 50), rand_range(-50, screensize.y + 50))

		while demon_position.x < screensize.x and demon_position.x > -30 and demon_position.y < screensize.y and demon_position.y > -35:
			demon_position = Vector2(rand_range(-40, screensize.x + 50), rand_range(-50, screensize.y + 50))

		var demon_instance = demons.instance()
		add_child(demon_instance)
		demon_instance.global_position = demon_position

# Start to spwan the monster wave by wave after each wave of monster died
func _on_Difficulty_spawn_timer_timeout():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		spawn_waves()

# function to spawn each wave of monsters.
func spawn_waves():
	zombie_wave()
	demon_wave()
	$Incoming_monster_sound.play()
	wave_notification.visible = true
	wave_notification.text = "Wave " + str(wave_num) + " started"
	wave_noti_timer.start(2.5)
	wave_num += 1
	zombie_spawn_number += 2
	demon_spawn_number += 2

# Once the timer hits 0, the wave_notification alert will be set to false
func _on_WaveNotification_timer_timeout():
	wave_notification.visible = false
