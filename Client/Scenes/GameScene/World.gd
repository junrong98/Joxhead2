extends Control

onready var bullet_manager = $BulletManager
onready var player: Player = $Player
onready var zombie_spawn_timing = $Zombie_spawn_timer
onready var demon_spawn_timing = $Demon_spawn_timer
onready var wave_notification = $GUI/WaveNotificationLabel

var zombies = preload("res://Scenes/GameScene/Zombie.tscn")
var demons = preload("res://Scenes/GameScene/Demon.tscn")
var wave_num = 1
var zombie_spawn_number = 20
var demon_spawn_number = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	#For bullets
	player.connect("fired_bullet", bullet_manager, "handle_bullet_spwaned")
	zombie_wave()
	wave_notification.text = "Wave " + str(wave_num) + " started"
	wave_num += 1

# Randomly spawn zombie outside of the screen size area
func zombie_wave():
	for i in range(0, zombie_spawn_number):
		var zombie_position = Vector2(rand_range(-40, 1070), rand_range(-50, 700))

		while zombie_position.x < 1020 and zombie_position.x > -30 and zombie_position.y < 650  and zombie_position.y > -35:
			zombie_position = Vector2(rand_range(-40, 1070), rand_range(-50, 700))

		var zombie_instance = zombies.instance()
		add_child(zombie_instance)
		zombie_instance.global_position = zombie_position

# Randomly spawn demon outside of the screen size area
func demon_wave():
	for j in range(0, demon_spawn_number):
		var demon_position = Vector2(rand_range(-40, 1070), rand_range(-50, 700))

		while demon_position.x < 1070 and demon_position.x > -30 and demon_position.y < 650 and demon_position.y > -35:
			demon_position = Vector2(rand_range(-40, 1070), rand_range(-50, 700))

		var demon_instance = demons.instance()
		add_child(demon_instance)
		demon_instance.global_position = demon_position

# Start to spwan the monster wave by wave every 20 secs
func _on_Difficulty_spawn_timer_timeout():
	zombie_wave()
	demon_wave()
	wave_notification.text = "Wave " + str(wave_num) + " started"
	wave_notification.visible = true
	wave_num += 1
	zombie_spawn_number += 2
	demon_spawn_number += 2
	


func _on_WaveNotification_timer_timeout():
	wave_notification.visible = false
