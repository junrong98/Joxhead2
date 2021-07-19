extends Control

remote func players_health(health):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "update_player_health", health)

remote func update_healthbar_colours(health):
	rpc("update_healthbars_colour", health)
