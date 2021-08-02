extends Node2D

onready var weapon_manager = $WeaponManager
onready var players = get_tree().get_root().find_node("Players", true, false)
onready var world = get_tree().root.get_node("(Multi)World")

var health = 100
var grenade = preload("res://Scenes/GameScene/Grenade.tscn")
var landmine = preload("res://Scenes/Multiplayer/(Multi)BombItems/(Multi)Landmine.tscn")
var fakewall = preload("res://Scenes/Multiplayer/(Multi)BombItems/(Multi)Fakewall.tscn")
var barrel = preload("res://Scenes/Multiplayer/(Multi)BombItems/(Multi)Barrel.tscn")

var grenade_count = 0

#Update player movement in the Multiplayer world
remote func update_player(transform):
	rpc_unreliable("update_remote_player", transform)

#Update player direction in the Multiplayer world
remote func update_player_sprite_dir(dir):
	rpc_unreliable("update_remote_player_dir", dir)

# Update the world when player died
remote func die():
	rpc("player_died")

# Remove the player sprite from the world
remote func remove_player(player_id):
	players.remove_child(players.get_node(player_id))

# Spawn Items in the Multiplayer world
remote func throw_grenades(num, uuid):
	var player_id = get_tree().get_rpc_sender_id()
	var grenade_instance = grenade.instance()
	grenade_instance.name = str(grenade_count)
	grenade_count += 1
	world.add_child(grenade_instance)
	rpc("throw_grenade", grenade_instance.name)
	rpc_unreliable_id(player_id, "grenade_update", num, uuid)

remote func plant_landmine(num, uuid):
	var player_id = get_tree().get_rpc_sender_id()
	var landmine_instance = landmine.instance()
	landmine_instance.name = str(landmine_instance.get_instance_id())
	world.add_child(landmine_instance)
	rpc("plant_landmines", landmine_instance.name)
	rpc_unreliable_id(player_id, "landmine_update", num, uuid)

remote func put_fakewall(num, uuid):
	var player_id = get_tree().get_rpc_sender_id()
	var fakewall_instance = fakewall.instance()
	fakewall_instance.name = str(fakewall_instance.get_instance_id())
	world.add_child(fakewall_instance)
	rpc("put_fakewalls", fakewall_instance.name)
	rpc_unreliable_id(player_id, "fakewall_update", num, uuid)

remote func put_barrel(num, uuid):
	var player_id = get_tree().get_rpc_sender_id()
	var barrel_instance = barrel.instance()
	barrel_instance.name = str(barrel_instance.get_instance_id())
	world.add_child(barrel_instance)
	rpc("put_barrels", barrel_instance.name)
	rpc_unreliable_id(player_id, "barrel_update", num, uuid)
