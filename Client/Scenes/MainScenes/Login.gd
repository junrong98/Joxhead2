extends Node2D

onready var mouse_hoversound = $MouseHover
onready var username : LineEdit = $MainPage/UsernameLabel/UsernameInput
onready var password : LineEdit = $MainPage/PasswordLabel/PasswordInput
onready var notification : Label = $MainPage/PopoutLabel
onready var loginBtn : TextureButton = $MainPage/LoginButton
onready var collection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var collection2 : FirestoreCollection = Firebase.Firestore.collection('user_inventory')

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "on_FirebaseAuth_login_failed")
	
func _on_LoginButton_pressed():
	if username.text.empty() or password.text.empty():
		notification.text = "Please, enter your username and password"
		return
	loginBtn.disabled = true
	Firebase.Auth.login_with_email_and_password(username.text, password.text)

func _on_LoginButton_mouse_entered():
	mouse_hoversound.play()

func _on_CreateAccountButton_mouse_entered():
	mouse_hoversound.play()

func _on_CreateAccountButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenes/AccountCreationPage.tscn")

func _on_FirebaseAuth_login_succeeded(auth):
	var user = Firebase.Auth.get_user_data()
	Global.uuid = auth["localid"]
	var document_task : FirestoreTask = collection.get(Global.uuid)
	var document : FirestoreDocument = yield(document_task, "get_document")
	var dict = document["doc_fields"]
	
	# User
	Global.highscore = dict["highscore"]
	Global.username = dict["username"]
	
	# User information
	var document_task2 : FirestoreTask = collection2.get(Global.uuid)
	var document2 : FirestoreDocument = yield(document_task2, "get_document")
	var dict2 = document2["doc_fields"]
	
	Global.gamedata = dict2
	
	Server.connect_to_server()
	
func on_FirebaseAuth_login_failed(error_code, message):
	loginBtn.disabled = false
	if error_code == 400:
		get_node("MainPage/PopoutLabel").text = "Invalid E-mail or password"
		

func _on_ForgetPasswordButton_pressed():
	var email = username.text
	if username.text.empty():
		notification.text = "Enter your email first"
		return
	Firebase.Auth.send_password_reset_email(email)
	notification.text = "Reset password email sent"


func _on_ForgetPasswordButton_mouse_entered():
	mouse_hoversound.play()
