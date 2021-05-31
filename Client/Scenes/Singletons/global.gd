extends Node

var uuid
var highscore
var game_highscore
var username
var gamedata
var updateHighScore = false

var ak47 = preload("res://Resources/Weapon_Sprite/AK-47.png")
var mp5 = preload("res://Resources/Weapon_Sprite/MP-5.png")
var spa12 = preload("res://Resources/Weapon_Sprite/Spas-12.png")

var invArr = ["AK47", "Uzi", "SPAS12"]
var invSprite = [ak47, mp5, spa12]
var invSize = invArr.size()
