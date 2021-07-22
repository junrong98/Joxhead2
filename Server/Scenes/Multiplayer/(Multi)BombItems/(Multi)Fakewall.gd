extends Node2D

onready var world = get_tree().root.get_node("(Multi)World")
onready var fakewall50 = load("res://Scenes/Multiplayer/(Multi)BombItems/fakewall(40).png")
onready var fakewall40 = load("res://Scenes/Multiplayer/(Multi)BombItems/fakewall(30).png")
onready var fakewall30 = load("res://Scenes/Multiplayer/(Multi)BombItems/fakewall(20).png")
onready var fakewall20 = load("res://Scenes/Multiplayer/(Multi)BombItems/fakewall(10).png")


remote func remove_wall():
	rpc("wall_removed")
	world.remove_child(self)
	queue_free()

remote func fakewall_health(fakewall_health):
	rpc("update_fakewall_texture", fakewall_health)
