extends Node2D

onready var mouse_hoversound = $MouseHover
onready var http : HTTPRequest = $HTTPRequest
onready var email : LineEdit = $EmailLabel/EmailInput
onready var username : LineEdit = $UsernameLabel/UsernameInput
onready var password : LineEdit = $PasswordLabel/PasswordInput
onready var confirm : LineEdit = $ConfirmPasswordLabel/ConfirmPasswordInput
onready var notification : Label = $PopoutLabel
onready var createBtn : TextureButton = $CreateButton

onready var collection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')
onready var collection2 : FirestoreCollection = Firebase.Firestore.collection('users')

func _ready():
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_FirebaseAuth_signup_failed")

func _on_CreateButton_mouse_entered():
	mouse_hoversound.play()

func _on_BackButton_mouse_entered():
	mouse_hoversound.play()

func _on_CreateButton_pressed():
	if password.text != confirm.text or username.text.empty() or password.text.empty() or email.text.empty() or confirm.text.empty():
		notification.text = "Invalid password or username"
		return
	createBtn.disabled = true
	Firebase.Auth.signup_with_email_and_password(email.text, password.text)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/Login.tscn")

func _on_FirebaseAuth_signup_succeeded(auth):
	var userid = auth["localid"]
		
	var add_task : FirestoreTask = collection.add("" + userid, \
	{"AK47_Ammo" : 10, "AK47_Dmg" : 5, "AK47_Range" : 7, "Credit" : 2000, "SPAS12_Ammo" : 6, "SPAS12_Dmg" : 20, "SPAS12_Range":2, "Uzi_Ammo" : 20, "Uzi_Dmg" : 2, "Uzi_Range" : 5})
	
	var add_task2 : FirestoreTask = collection2.add("" + userid, \
	{"highscore" : 0, "username" : username.text})
	
	get_tree().change_scene("res://Scenes/MainScenes/Login.tscn")
	
func _on_FirebaseAuth_signup_failed(error_code, msg):
	createBtn.disabled = false
	if error_code == 400:
		if msg == "EMAIL_EXISTS":
			get_node("PopoutLabel").text = "Email already exists"
		elif msg == "INVALID_EMAIL":
			get_node("PopoutLabel").text = "Invalid E-mail"
		
