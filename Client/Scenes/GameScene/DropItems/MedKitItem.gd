extends Area2D

func _ready():
	pass # Replace with function body.

# When players enter the medkit, it will heal the player HP
func _on_MedKitItem_body_entered(body):
	if body.is_in_group("Players"):
		body.add_health(15)
		queue_free()
