extends Node2D

onready var world = get_tree().root.get_node("(Multi)World")

remote func remove_landmine():
	rpc("landmine_removed")
	world.remove_child(self)
	queue_free()
