extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# When the players pick up the coin drop loots
func _on_CoinsItem_body_entered(body):
	if body.is_in_group("Players"):
		body.add_coins()
		queue_free()
