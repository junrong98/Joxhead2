extends Node2D

var fakewall_health = 50
onready var fakewall50 = load("res://Sprites/BombItem/fakewall(40).png")
onready var fakewall40 = load("res://Sprites/BombItem/fakewall(30).png")
onready var fakewall30 = load("res://Sprites/BombItem/fakewall(20).png")
onready var fakewall20 = load("res://Sprites/BombItem/fakewall(10).png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy_object(dmg):
	fakewall_health -= dmg
	if fakewall_health <= 40:
		$FakewallSprite.set_texture(fakewall50)
	if fakewall_health <= 30:
		$FakewallSprite.set_texture(fakewall40)
	if fakewall_health <= 20:
		$FakewallSprite.set_texture(fakewall30)
	if fakewall_health <= 10:
		$FakewallSprite.set_texture(fakewall20)
	if fakewall_health < 0:
		# To remove the mode of the Fakwall
		get_parent().queue_free()

func bomb_hit(dmg):
	destroy_object(dmg)


func _on_FakewallArea_body_exited(body):
	$FakewallStaticBody.set_collision_mask_bit(0,true)
	$FakewallStaticBody.set_collision_layer_bit(0,true)
	$FakewallStaticBody.set_collision_mask_bit(2,true)
	$FakewallStaticBody.set_collision_layer_bit(2,true)
