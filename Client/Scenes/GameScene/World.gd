extends Control

onready var bullet_manager = $BulletManager
onready var player = $Player
onready var weapon_manager = $Player/PlayerSprite/WeaponManager
onready var zombie_spawn_timing = $Zombie_spawn_timer
onready var demon_spawn_timing = $Demon_spawn_timer
onready var wave_notification = $GUI/WaveNotificationLabel
onready var wave_noti_timer = $GUI/WaveNotificationLabel/WaveNotification_timer
onready var grenade_num_label = $ItemGUI/GrenadePanel/GreandeLabel
onready var landmine_num_label = $ItemGUI/LandminePanel/LandmineLabel
onready var fakewall_num_label = $ItemGUI/FakewallPanel/FakewallLabel
onready var barrel_num_label = $ItemGUI/BarrelPanel/BarrelLabel

var zombies = preload("res://Scenes/GameScene/Zombie.tscn")
var demons = preload("res://Scenes/GameScene/Demon.tscn")
var wave_num = 1
var zombie_spawn_number = 14
var demon_spawn_number = 0
var screensize

# Called when the node enters the scene tree for the first time. Spawn waves() function
# to automatically spawn the first wave.
func _ready():
	#For bullets
	weapon_manager.connect("fired_bullet", bullet_manager, "handle_bullet_spwaned")
	player.connect("grenade_num_update", self, "grenade_update")
	player.connect("landmine_num_update", self, "landmine_update")
	player.connect("fakewall_num_update", self, "fakewall_update")
	player.connect("barrel_num_update", self, "barrel_update")
	screensize = get_viewport_rect().size
	grenade_num_label.text = str(player.num_grenade)
	landmine_num_label.text = str(player.num_landmine)
	fakewall_num_label.text = str(player.num_fakewall)
	barrel_num_label.text = str(player.num_barrel)


func grenade_update(num):
	grenade_num_label.text = str(num)

func landmine_update(num):
	landmine_num_label.text = str(num)

func fakewall_update(num):
	fakewall_num_label.text = str(num)

func barrel_update(num):
	barrel_num_label.text = str(num)

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
