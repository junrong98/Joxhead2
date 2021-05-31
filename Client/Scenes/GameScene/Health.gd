extends Node2D

export (int) var health = 10 setget set_health

# Set the health of the player. Will be useful when start implementing medkit
func set_health(new_health: int):
	health = clamp(new_health,0, 100)
