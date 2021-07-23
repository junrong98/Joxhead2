extends Node

var userCollection
var userInventoryCollection

# Volume settings
var currentBgVolume
var currentSFXvoume

var controlSettings
var soundSettings

# Multiplayer
var roomArr
var roomName = ""
var isLeader = false

var userReady
var otherReady

var email
var uuid
var highscore
var game_highscore = 0
var username
var gamedata
var updateHighScore = false

var coin_earn = 0

var settings

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

# Base stats
var weaponStats : Dictionary = {"Credit" : 500,\
	"Basic" : {"Ammo" : 70, "Dmg" : 10, "Range" : 5,\
			   "Ammo_Lvl" : 1, "Dmg_Lvl" : 1, "Range_Lvl" : 1,\
			   "Unlocked": true, "Unlocked_Cost": 0, "Upgrade_Cost": 3, "Type" : "Weapon",\
			   "Description" : "Basic weapon to survive this apocalypse"},
	"AK47" : {"Ammo" : 100, "Dmg" : 30, "Range" : 7,\
			  "Ammo_Lvl" : 1, "Dmg_Lvl" : 1, "Range_Lvl" : 1,\
			  "Unlocked": false, "Unlocked_Cost": 20, "Upgrade_Cost": 6, "Type" : "Weapon",\
			  "Description" : "Easily dispatched any zombie with the one-and-only AK47."},
	"SPAS12" : {"Ammo" : 50, "Dmg" : 50, "Range":2,\
				"Ammo_Lvl" : 1, "Dmg_Lvl" : 1, "Range_Lvl": 1,\
				"Unlocked": false, "Unlocked_Cost": 150, "Upgrade_Cost": 8, "Type" : "Weapon",\
				"Description" : "Strong weapon with heavy damage to the monsters"},
	"Uzi" : {"Ammo" : 200, "Dmg" : 25, "Range" : 5,\
			 "Ammo_Lvl" : 1, "Dmg_Lvl" : 1, "Range_Lvl" : 1,\
			 "Unlocked": false, "Unlocked_Cost": 100, "Upgrade_Cost": 4, "Type" : "Weapon",\
			 "Description" : "Rapid fire to clear wave fast and furious."},
	"Mine" : {"Ammo" : 10, "Dmg" : 60, 	"Unlocked" : true, "Price" : 10, "Type" : "Item",\
			  "Description" : "Goes tick-tick boom when monsters step on it."},
	"Barrel" : {"Ammo" : 10, "Dmg" : 60, 	"Unlocked" : true, "Price" : 15, "Type" : "Item",\
				"Description" : "Explode when you shoot at it."},
	"Grenade" : {"Ammo" : 10, "Dmg" : 60, 	"Unlocked" : true, "Price" : 15, "Type" : "Item",\
				 "Description" : "Goes kaboom when you throw it."},
	"Fake_Wall" : {"Ammo" : 10, "Health" : 50, "Unlocked" : true, "Price" : 10, "Type" : "Defensive",\
			  	   "Description" : "A temporary wall to protect you from harm"}
	}
	
func setData(playerUuid, playerHighscore, playerGamedata, playerUsername,\
			 playerSetting,
			 userCollectionData, userInventoryData):
	uuid = playerUuid
	highscore = playerHighscore
	gamedata = playerGamedata
	username = playerUsername
	userCollection = userCollectionData
	userInventoryCollection = userInventoryData
	settings = playerSetting
	controlSettings = playerSetting["control"]
	soundSettings = playerSetting["sound"]
	
	currentBgVolume = soundSettings["backgroundMusicVolume"]
	currentSFXvoume = soundSettings["sfxVolume"]
	
	ControlScript.file_name = "res://" + str(Global.uuid) + ".json"
	ControlScript.setKeyDict(controlSettings)
	ControlScript.load_keys()
	
	# Once login is successful set sound setting based on user settings
	BackgroundMusic.setMusicVolume(soundSettings["backgroundMusicVolume"])
	# Note: -70 is required to allow sfx volume to be safe for the ears
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), soundSettings["sfxVolume"] - 70)

func resetGlobal():
	setData(null, null, null, null, null, null, null)

func resetMultiplayerData():
	roomName = ""
	isLeader = false
	userReady = null
	otherReady = null
	coin_earn = 0

	

