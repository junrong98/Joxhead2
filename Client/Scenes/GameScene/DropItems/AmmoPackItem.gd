extends Area2D


# When the player walk to the ammopack, it will add the number of ammo in players weapon
func _on_AmmoPackItem_body_entered(body):
	if body.is_in_group("Players"):
		body.add_ammo(10)
		queue_free()
