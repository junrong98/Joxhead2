extends Node2D

var previous_weapon = "Basic"

remote func player_bullet():
	rpc("spawn_bullet")

remote func change_next():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "change_next_weapon")

remote func change_previous():
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id,"change_previous_weapon")

remote func set_weapon(curr_weapon):
	rpc("update_weapon_text", str(curr_weapon), curr_weapon, previous_weapon)
	previous_weapon = curr_weapon

remote func set_weapon_ammo(weapon_ammo):
	rpc("update_weapon_ammo", str(weapon_ammo))
