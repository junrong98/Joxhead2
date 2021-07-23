extends Node2D

onready var world = get_tree().root.get_node("(Multi)World")

remote func barrel_explode(health):
	rpc("barrel_exploded", health)

remote func remove_barrel():
	rpc("barrel_removed")
	world.remove_child(self)
	queue_free()
	
