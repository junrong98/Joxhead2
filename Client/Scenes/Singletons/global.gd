extends Node

# Multiplayer
var roomArr
var roomName = ""
var isLeader = false

var uuid
var highscore
var game_highscore
var username
var gamedata
var updateHighScore = false

var grenade = preload("res://Sprites/BombItem/hand_grenade.png")
var mine = preload("res://Sprites/BombItem/redLandmine.png")
var fake_wall = preload("res://Sprites/BombItem/fakewall.png")
var barrel = preload("res://Sprites/BombItem/barrel.png")

var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var uzi = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")
var basic = preload("res://Resources/Weapon_Sprite/Basic.png")

var invArr = ["Basic", "AK47", "Uzi", "SPAS12", "Mine", "Barrel", "Grenade", "Fake_Wall"]
var invSprite = [basic, ak47, uzi, spa12, mine, barrel, grenade, fake_wall]
var invSize = invArr.size()
