extends Node2D

const PLAYER = preload("res://Scenes/Multiplayer/(Multi)Player.tscn")
const ZOMBIES = preload("res://Scenes/Multiplayer/(Multi)Zombie.tscn")
const DEMONS = preload("res://Scenes/Multiplayer/(Multi)Demon.tscn")

onready var player_spawn = $PlayerSpawn1
onready var player_spawn2 = $PlayerSpawn2
onready var players = $Players
onready var zombies = $Zombies
onready var demons = $Demons
onready var curr_score = $GUI/ScoreContainer/ScoreLabel
onready var zombie_spawn = $ZombieSpawn
onready var demon_spawn = $DemonSpawn

onready var game_over = preload("res://Scenes/Multiplayer/GameOverGui.tscn")

var med_kit_scene = preload("res://Scenes/GameScene/DropItems/MedKitItem.tscn")
var ammo_pack_scence = preload("res://Scenes/GameScene/DropItems/AmmoPackItem.tscn")
var coins_scence = preload("res://Scenes/GameScene/DropItems/CoinsItem.tscn")

var zombie_spawn_number = 10
var demon_spawn_number = 10

var zombie_position_list
var demon_position_list
var spawn_point = ["PlayerSpawn1", "PlayerSpawn2"]
var spawn_num = 0
var screensize

func _ready():
	zombie_position_list = zombie_spawn.get_children()
	demon_position_list = demon_spawn.get_children()
	rpc_id(1, "spawn_players", get_tree().get_network_unique_id(), Global.username)
	screensize = get_viewport_rect().size

func add_score(score):
	rpc_id(1, "current_scores", score)

sync func update_score(score):
	Global.game_highscore = score
	get_node("GUI/ScoreContainer/ScoreLabel").set_text(str(score))

remote func spawn_player(id, username):
	var player = PLAYER.instance()
	player.name = str(id)
	player.set_player_name(username)
	players.add_child(player)
	player.set_network_master(id)
	var spawn_pos = get_node(spawn_point[spawn_num])
	spawn_num += 1
	player.position = spawn_pos.position


remote func spawn_demon(idx, demon_name):
	var new_destination = demon_position_list[idx]
	var demon_instance = DEMONS.instance()
	demon_instance.name = demon_name
	demons.add_child(demon_instance)
	demon_instance.position = new_destination.position

remote func spawn_zombie(idx, zombie_name):
	var new_destination = zombie_position_list[idx]
	var zombie_instance = ZOMBIES.instance()
	zombie_instance.name = zombie_name
	zombies.add_child(zombie_instance)
	zombie_instance.position = new_destination.position

func _on_Difficulty_spawn_timer_timeout():
	#if get_tree().get_nodes_in_group("Enemy").size() == 0:
		#if Global.isLeader:
			#for i in range(0, zombie_spawn_number):
	rpc_id(1, "spawn_zombies", zombie_position_list.size())
	rpc_id(1, "spawn_demons", demon_position_list.size())


func spawn_medkit(pos):
	rpc_id(1, "spawn_medkit", pos)

func spawn_ammopack(pos):
	rpc_id(1, "spawn_ammopack", pos)

func spawn_coins(pos):
	rpc_id(1, "spawn_coins", pos)

remote func add_medkit(pos, medkit_id):
	var medkit = med_kit_scene.instance()
	medkit.name = medkit_id
	add_child(medkit)
	medkit.position = pos

remote func add_ammopack(pos, ammo_id):
	var ammopack = ammo_pack_scence.instance()
	ammopack.name = ammo_id
	add_child(ammopack)
	ammopack.position = pos

remote func add_coins(pos, coin_id):
	var coins = coins_scence.instance()
	coins.name = coin_id
	add_child(coins)
	coins.position = pos

func show_gameover():
	if players.get_children().size() == 0:
		$GameOverGui/GameOverGui.visible = true
		get_tree().paused = true

remote func player_disconnected(player_id):
	players.get_node(str(player_id)).queue_free()
