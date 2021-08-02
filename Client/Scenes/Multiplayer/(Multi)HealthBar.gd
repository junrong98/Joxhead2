extends Control

onready var health_bar_over = $Node2D/HealthBarOver
onready var health_bar_under = $Node2D/HealthBarUnder
onready var update_tween = $UpdateTween

var players_health = 100
var healthy_colour = Color.green
var caution_colour = Color.yellow
var danger_colour = Color.red

#Add health
func health_added(add_health):
	if players_health + add_health > 100:
		players_health = 100
	else:
		players_health += add_health
	
	rpc_id(get_tree().get_rpc_sender_id(), "players_health", players_health)

# Reduce health
func health_deducted(deduct_health):
	players_health -= deduct_health
	rpc_id(get_tree().get_rpc_sender_id(), "players_health", players_health)

# Update the healthbar colour for the player
sync func update_player_health(health):
	rpc_id(get_tree().get_rpc_sender_id(), "update_healthbar_colours", players_health)

# Update the healthbar colour for all clients
sync func update_healthbars_colour(health):
	players_health = health
	if health < 60 && health > 30:
		health_bar_over.value = health
		health_bar_over.tint_progress = caution_colour
		update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		update_tween.start()
	elif health <= 30:
		health_bar_over.value = health
		update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		update_tween.start()
		health_bar_over.tint_progress = danger_colour
	else:
		health_bar_over.value = health
		update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		update_tween.start()
		health_bar_over.tint_progress = healthy_colour

func max_health_update(max_health):
	health_bar_over.max_value = max_health
	health_bar_under.max_value = max_health
