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

var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var uzi = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")
var basic = preload("res://Resources/Weapon_Sprite/Basic.png")

var invArr = ["Basic", "AK47", "Uzi", "SPAS12"]
var invSprite = [basic, ak47, uzi, spa12]
var invSize = invArr.size()
