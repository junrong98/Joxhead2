extends Node2D

onready var players = get_tree().get_root().find_node("Players", true, false)
onready var zombie_parent = get_tree().get_root().find_node("Demons", true, false)
onready var world = get_tree().root.get_node("(Multi)World")
onready var blood_particle = preload("res://Scenes/GameScene/BloodParticles.tscn")

var health

func _ready():
	randomize()

remote func select_target():
	var num_players = players.get_children().size()
	if num_players != 0:
		var player_idx = randi() % num_players
		rpc("select_player_target", player_idx)

remote func demon_get_hit(demon_id, dmg):
	health -= dmg
	if health <= 0:
		rpc("remove_demon")
		queue_free()

remote func blood(pos):
	var blood_instance = blood_particle.instance()
	blood_instance.global_position = pos
	world.add_child(blood_instance)
	rpc("spawn_blood", pos)
