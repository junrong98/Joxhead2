extends Node2D

onready var player_camera = get_node("/root/World/Player/Camera2D")

func _ready():
	set_camera_limits()

# Setting the camera limit from the players to be not out of the map tile size.
func set_camera_limits():
	var map_limits = $Wall.get_used_rect()
	var map_cellsize = $Wall.cell_size
	player_camera.limit_left = map_limits.position.x * map_cellsize.x
	player_camera.limit_right = map_limits.end.x * map_cellsize.x
	player_camera.limit_top = map_limits.position.y * map_cellsize.y
	player_camera.limit_bottom = map_limits.end.y * map_cellsize.y
