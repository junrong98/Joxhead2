extends Control

onready var health_bar_over = $Node2D/HealthBarOver
onready var health_bar_under = $Node2D/HealthBarUnder
onready var update_tween = $UpdateTween

var players_health = 100
var healthy_colour = Color.green
var caution_colour = Color.yellow
var danger_colour = Color.red

func health_added(add_health):
	if players_health + add_health > 100:
		players_health = 100
	else:
		players_health += add_health
	
	health_bar_over.value = players_health
	update_healthbar_colour()

func health_deducted(deduct_health):
	players_health -= deduct_health
	health_bar_over.value = players_health
	update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, players_health, 0.4, Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	update_tween.start()
	
	update_healthbar_colour()

func update_healthbar_colour():
	if players_health < 60 && players_health > 30:
		health_bar_over.tint_progress = caution_colour
	elif players_health <= 30:
		health_bar_over.tint_progress = danger_colour
	else:
		health_bar_over.tint_progress = healthy_colour

func max_health_update(max_health):
	health_bar_over.max_value = max_health
	health_bar_under.max_value = max_health
