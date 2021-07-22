extends Node2D

const PLAYER = preload("res://Scenes/Multiplayer/(Multi)Player.tscn")
const ZOMBIES = preload("res://Scenes/Multiplayer/(Multi)Zombie.tscn")
const DEMONS = preload("res://Scenes/Multiplayer/(Multi)Demon.tscn")


onready var players = $Players
onready var zombies = $Zombies
onready var demons = $Demons
var medkit = preload("res://Scenes/GameScene/MedKitItem.tscn")
var ammo_pack = preload("res://Scenes/GameScene/AmmoPackItem.tscn")
var coins = preload("res://Scenes/GameScene/CoinsItem.tscn")

var zombie_count = 0
var demon_count = 0
var medkit_count = 0
var ammo_count = 0
var coin_count = 0
var current_score = 0


remote func spawn_players(id, username):
	var player = PLAYER.instance()
	player.name = str(id)
	players.add_child(player)
	rpc("spawn_player", id, username)

remote func spawn_zombies(pos):
	var zombie_instance = ZOMBIES.instance()
	var idx = randi() % pos
	zombie_instance.name = str(zombie_count)
	zombie_instance.health = 60
	zombie_count += 1
	zombies.add_child(zombie_instance)
	rpc("spawn_zombie",idx, zombie_instance.name)

#remote func spawn_zombies(pos):
#	var zombie_instance = ZOMBIES.instance()
#	#var idx = randi() % pos
#	zombie_instance.name = str(zombie_count)
#	print(zombie_count)
#	zombie_instance.health = 60
#	zombies.add_child(zombie_instance)
#	rpc("spawn_zombie",zombie_count, zombie_instance.name)
#	zombie_count += 1

remote func spawn_demons(pos):
	var demon_instance = DEMONS.instance()
	var idx = randi() % pos
	demon_instance.name = str(demon_count)
	demon_instance.health = 100
	demon_count += 1
	demons.add_child(demon_instance)
	rpc("spawn_demon",idx, demon_instance.name)

remote func spawn_medkit(pos):
	var medkit_instance = medkit.instance()
	medkit_instance.name = str(medkit_count)
	medkit_count += 1
	add_child(medkit_instance)
	rpc("add_medkit", pos, medkit_instance.name)

remote func spawn_ammopack(pos):
	var ammo_instance = ammo_pack.instance()
	ammo_instance.name = str(ammo_count)
	ammo_count += 1
	add_child(ammo_instance)
	rpc("add_ammopack", pos, ammo_instance.name)

remote func spawn_coins(pos):
	var coin_instance = coins.instance()
	coin_instance.name = str(coin_count)
	coin_count += 1
	add_child(coin_instance)
	rpc("add_coins", pos, coin_instance.name)

remote func current_scores(score):
	current_score += score
	rpc("update_score", current_score)

func delete_player(player_id):
	players.get_node(str(player_id)).queue_free()
	rpc("player_disconnected", player_id)

remote func remove_barrel(barrel_id):
	print("barrel")
	get_node(str(barrel_id)).queue_free()
	rpc("barrel_removed", barrel_id)
