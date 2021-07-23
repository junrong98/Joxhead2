extends TextureRect
onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var emailInpt = $MarginContainer/VBoxContainer/VBoxContainer/emailInpt
onready var usernameInpt = $MarginContainer/VBoxContainer/VBoxContainer2/usernameInpt

onready var emailErrLbl = $MarginContainer/VBoxContainer/VBoxContainer/errLabel
onready var userNameErrLbl = $MarginContainer/VBoxContainer/VBoxContainer2/errLabel
var preDisconnectScene = preload("res://Scenes/MainScenesV2/Disconnect.tscn")

func _ready():
	usernameInpt.text = Global.username
	emailInpt.text = Global.email
	$usernameLabel.text = Global.username
	Firebase.Auth.connect("request_completed", self, "auth_user_request")
	userCollection.connect("error", self, "update_error")
	Server.network.connect("connection_failed", self, "_on_connection_failed")
	Server.network.connect("server_disconnected", self, "_on_server_disconnect")

func _on_connection_failed():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)
	
func _on_server_disconnect():
	var disconnectScene = preDisconnectScene.instance()
	add_child(disconnectScene)

func _on_backButton_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/Setting.tscn")

func _on_emailInpt_mouse_entered():
	emailInpt.editable = true

func _on_emailInpt_mouse_exited():
	if emailInpt.text == Global.email:
		emailInpt.editable = false

func _on_usernameInpt_mouse_entered():
	usernameInpt.editable = true

func _on_usernameInpt_mouse_exited():
	if usernameInpt.text == Global.username:
		usernameInpt.editable = false

func auth_user_request(result, response_code, headers, body):
	if response_code == 400:
		emailErrLbl.text = "Email already exists"
		emailErrLbl.add_color_override("font_color", Color(1,0,0))
	elif response_code == 200:
		emailErrLbl.text = "Email changed successfully"
		emailErrLbl.add_color_override("font_color", Color(0,1,0))


func _on_changePasswordBtn_pressed():
	get_tree().change_scene("res://Scenes/MainScenesV2/ChangePassword.tscn")


func _on_saveChangesBtn_pressed():
	if usernameInpt.text != Global.username: # There is a change in username
		if ($usernameLabel.text.empty()):
			userNameErrLbl.text = "Please enter a valid username"
			userNameErrLbl.add_color_override("font_color", Color(1,0,0))
		elif (" " in $usernameLabel.text):
			userNameErrLbl.text = "No spaces allowed in username"
			userNameErrLbl.add_color_override("font_color", Color(1,0,0))
		else:
			var newUsername = usernameInpt.text
			userCollection.update(Global.uuid, {"highscore" : Global.highscore, "username" : newUsername, "settings" : Global.settings})
			Global.username = newUsername
			$usernameLabel.text = newUsername
			usernameInpt.text = newUsername
			userNameErrLbl.text = "Username changes successfully"
			userNameErrLbl.add_color_override("font_color", Color(0,1,0))
	if emailInpt.text != Global.email:
		if (" " in $usernameLabel.text):
			emailErrLbl.text = "Enter a valid E-mail address"
			emailErrLbl.add_color_override("font_color", Color(1,0,0))
		else:
			Firebase.Auth.change_user_email(emailInpt.text)
