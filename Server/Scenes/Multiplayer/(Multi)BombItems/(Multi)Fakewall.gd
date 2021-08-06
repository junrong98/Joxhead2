extends Node2D

onready var world = get_tree().root.get_node("(Multi)World")

remote func remove_wall():
	rpc("wall_removed")
	world.remove_child(self)
	queue_free()

remote func fakewall_health(fakewall_health):
	rpc("update_fakewall_texture", fakewall_health)
