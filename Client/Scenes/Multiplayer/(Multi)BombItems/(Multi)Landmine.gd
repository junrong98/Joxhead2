extends Area2D

export var animations = []

var land_mine_time = 2
var dmg = 60

onready var landmine_timer = $LandmineTimer
onready var AOEdmg = $AOEAttack

func _ready():
	play_landmine_ani(0)

# Changing the animation of the landmine Sprite
# 0 -> Idle animation
# 1 -> Flashing animation	
func play_landmine_ani(aniIndex:int):
	$LandmineSprite.animation = animations[aniIndex]

func AOEAttack():
	var targets = AOEdmg.get_overlapping_bodies()
	$AOEAttack/ExplosionSprite.play()
	for target in targets:
		target.bomb_hit(dmg)

func _on_Landmine_body_entered(body):
	if body.is_in_group("Enemy"):
		play_landmine_ani(1)
		landmine_timer.start(land_mine_time)

func _on_LandmineTimer_timeout():
	AOEAttack()
	$LandmineSprite.visible = false

func _on_ExplosionSprite_animation_finished():
	rpc_id(1, "remove_landmine")

remote func landmine_removed():
	self.queue_free()
