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
onready var zombie_remainding_label = $ItemGUI/ZombiePanel/ZombieNumLabel
onready var demon_remainding_label = $ItemGUI/DemonPanel/DemonNumLabel

var zombies = preload("res://Scenes/GameScene/Zombie.tscn")
var demons = preload("res://Scenes/GameScene/Demon.tscn")
var wave_num = 1
var zombie_spawn_number = 14
var demon_spawn_number = 0
var num_of_zombie_left = zombie_spawn_number
var num_of_demon_left = demon_spawn_number
var screensize
var spawn_loc = Array()
var min_dist = 65

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
#	demon_remainding_label.text = str(num_of_demon_left)
#	zombie_remainding_label.text = str(num_of_zombie_left)

func _process(delta):
	demon_remainding_label.text = str(num_of_demon_left)
	zombie_remainding_label.text = str(num_of_zombie_left)

func grenade_update(num):
	grenade_num_label.text = str(num)

func landmine_update(num):
	landmine_num_label.text = str(num)

func fakewall_update(num):
	fakewall_num_label.text = str(num)

func barrel_update(num):
	barrel_num_label.text = str(num)

func zombie_wave():
	for i in range(0, zombie_spawn_number):
		var nextLoc = getNextSpawnLoc()
		var zombie_instance = zombies.instance()
		add_child(zombie_instance)
		zombie_instance.global_position = nextLoc

func demon_wave():
	for j in range(0, demon_spawn_number):
		var nextLoc = getNextSpawnLoc()
		var demon_instance = demons.instance()
		add_child(demon_instance)
		demon_instance.global_position = nextLoc

func getNextSpawnLoc():
	while true:
		var pos = Vector2(rand_range(-180, screensize.x + 170), rand_range(-180, screensize.y + 170))
		while pos.x < screensize.x and pos.x > -165 and pos.y < screensize.y and pos.y > -165:
			pos  = Vector2(rand_range(-150, screensize.x + 150), rand_range(-150, screensize.y + 150))
		var newLoc = pos
		var tooClose = false
		for loc in spawn_loc:
			if newLoc.distance_to(loc) < min_dist:
				tooClose = true;
				break;
		if !tooClose:
			spawn_loc.append(newLoc)
			return newLoc

# Start to spwan the monster wave by wave after each wave of monster died
func _on_Difficulty_spawn_timer_timeout():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		spawn_waves()

# function to spawn each wave of monsters.
func spawn_waves():
	spawn_loc = Array()
	zombie_wave()
	demon_wave()
	$Incoming_monster_sound.play()
	wave_notification.visible = true
	wave_notification.text = "Wave " + str(wave_num) + " started"
	wave_noti_timer.start(2.5)
	wave_num += 1
	zombie_spawn_number += 2
	demon_spawn_number += 2
	num_of_demon_left = demon_spawn_number - 2
	num_of_zombie_left = zombie_spawn_number - 2

# Once the timer hits 0, the wave_notification alert will be set to false
func _on_WaveNotification_timer_timeout():
	wave_notification.visible = false
