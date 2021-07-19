extends TextureRect

onready var loginForm = $loginForm
onready var userCollection : FirestoreCollection = Firebase.Firestore.collection('users')
onready var userInventoryCollection : FirestoreCollection = Firebase.Firestore.collection('user_inventory')

# Login = 0, Signup = 1, Reset = 2
var loginOrSignupOrReset

func startLoadingAnimation():
	$loadingPanel.visible = true
	$loadingAnimationG1.play("loadingGrenade")
	$loadingAnimationG2.play("loadingGrenade")
	$loadingAnimationG3.play("loadingGrenade")

func stopLoadingAnimation():
	$loadingPanel.visible = false
	$loadingAnimationG1.stop()
	$loadingAnimationG2.stop()
	$loadingAnimationG3.stop()
	$loadingGrenade1.visible = false
	$loadingGrenade2.visible = false
	$loadingGrenade3.visible = false

func _ready():
	BackgroundMusic.play_music()
	# -20 is the default volume for SFX
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -20)
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "on_FirebaseAuth_login_signup_failed")
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("request_completed", self, "_get_FirebaseAuth_completed_request")


func _on_loginBtnAnimation_animation_finished(anim_name):
	$loginBtnSprite.visible = false
	$loginButton.visible = true

func _on_createBtnAnimation_animation_finished(anim_name):
	$createAccSprite.visible = false
	$createAccButton.visible = true

func _on_loginButton_pressed():
	loginOrSignupOrReset = 0
	$loginForm.visible = true

func _on_createAccButton_pressed():
	loginOrSignupOrReset = 1
	$signUpForm.visible = true

# Login form
onready var usernameInpt = $loginForm/VBoxContainer/VBoxContainer/usernameInpt
onready var passwordInpt = $loginForm/VBoxContainer/VBoxContainer2/passwordInpt
onready var loginErrLbl = $loginForm/loginErrLbl

func _on_closeBtn_pressed():
	loginForm.visible = false
	usernameInpt.text = ""
	passwordInpt.text = ""
	
func _on_loginBtn_pressed():
	if usernameInpt.text.empty() || passwordInpt.text.empty():
		loginErrLbl.text = "Invalid username or password."
		loginErrLbl.add_color_override("font_color", Color(1,0,0))
	else:
		startLoadingAnimation()
		Firebase.Auth.login_with_email_and_password(usernameInpt.text, passwordInpt.text)

func _on_FirebaseAuth_login_succeeded(auth):
	var user = Firebase.Auth.get_user_data()
	var uuid = auth["localid"]
	
	# Once we get UUID, we immediately check if user is already logged in
	
	var verifyUserTask : FirestoreTask = userCollection.get(uuid)
	var userDoc : FirestoreDocument = yield(verifyUserTask, "get_document")
	var userDict = userDoc["doc_fields"]
	
	# User information
	var getUserData : FirestoreTask = userInventoryCollection.get(uuid)
	var userDataDoc : FirestoreDocument = yield(getUserData, "get_document")
	var userDataDict = userDataDoc["doc_fields"]
	
	
	Global.email = usernameInpt.text

	Global.setData(uuid, userDict["highscore"], userDataDict, userDict["username"],\
				   userDict["settings"],\
				   userCollection, userInventoryCollection)
	
	Server.connect_to_server()

func resetFormOpen():
	$forgetPasswordForm.visible = true
	usernameInpt.text = ""
	passwordInpt.text = ""
	loginForm.visible = false
		
# Signup Form
onready var newUsernameInpt = $signUpForm/VBoxContainer/VBoxContainer/HBoxContainer/usernameInpt
onready var newEmailInpt = $signUpForm/VBoxContainer/VBoxContainer/HBoxContainer/emailInpt
onready var newPasswordInpt = $signUpForm/VBoxContainer/VBoxContainer2/passwordInpt
onready var cfmNewPasswordInpt = $signUpForm/VBoxContainer/VBoxContainer3/cfmPasswordInpt
onready var newUsername = $signUpForm/VBoxContainer/VBoxContainer/HBoxContainer/usernameInpt
onready var signUpErrLbl = $signUpForm/signUpErrLbl

func signUpError(message):
	signUpErrLbl.text = message
	signUpErrLbl.add_color_override("font_color", Color(1,0,0))

func signUpSuccess():
	signUpErrLbl.text = "Account successfully created"
	signUpErrLbl.add_color_override("font_color", Color(0,1,0))

func clearSignUpForm():
	newUsernameInpt.text = ""
	newEmailInpt.text = ""
	newPasswordInpt.text = ""
	cfmNewPasswordInpt.text = ""
	
func _on_createAccCloseBtn_pressed():
	$signUpForm.visible = false
	clearSignUpForm()
	
func _on_createAccBtn_pressed():
	if newEmailInpt.text.empty() || newEmailInpt.text.empty() || newPasswordInpt.text.empty()\
		|| cfmNewPasswordInpt.text.empty() || newUsernameInpt.text.empty():
		signUpError("Please fill up the required fields")
	else:
		var newPassword = newPasswordInpt.text
		var cfmNewPassword = cfmNewPasswordInpt.text
		var newEmail = newEmailInpt.text
		
		if newPassword != cfmNewPassword:
			signUpError("Password do not match")
		else: # No errors, proceed to send user email and password to firebase for further verification
			startLoadingAnimation()
			Firebase.Auth.signup_with_email_and_password(newEmail, newPassword)

func _on_FirebaseAuth_signup_succeeded(auth):
	var userid = auth["localid"]
	
	var addUserData : FirestoreTask = userInventoryCollection.add("" + userid, {"Credit" : 500,\
	"Basic" : {"Ammo" : 50, "Dmg" : 10, "Range" : 5,\
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
	})
	
	var add_task2 : FirestoreTask = userCollection.add("" + userid, \
		{ "highscore" : 0, "username" : newUsernameInpt.text, \
			 "settings" : { 
				"control" : {
					"up_W":87, "down_S":83, "left_A":65, "right_D":68, 
					"next_weapon":69,"previous_weapon":81, "throw_item":90, "plant_landmine":88,
					"place_fakewall": 67, "place_barrel":86
					},
				"sound" : {
					"backgroundMusicVolume" : 50,
					"sfxVolume" : 50
					}
				}
			}
		)
	yield(get_tree().create_timer(1),"timeout")
	$signUpForm.visible = false
	clearSignUpForm()
				
func _on_forgetPwLabel_mouse_entered():
	$loginForm/forgetPwLabel.bbcode_text = "[url='resetFormOpen'][u]Forget password?[/u][/url]"

func _on_forgetPwLabel_mouse_exited():
	$loginForm/forgetPwLabel.bbcode_text = "Forget password?"

# Reset password
onready var forgetForm = $forgetPasswordForm
onready var resetLbl = $forgetPasswordForm/resetPwLbl
onready var emailInpt = $forgetPasswordForm/VBoxContainer/VBoxContainer/usernameInpt

func _on_resetCloseBtn_pressed():
	forgetForm.visible = false
	emailInpt.text = ""
	resetLbl.text = ""
	resetLbl.visible = false

func _on_forgetPwLabel_meta_clicked(meta):
	resetFormOpen()

func resetLabelErr(message, color):
	resetLbl.visible = true
	resetLbl.text = message
	resetLbl.add_color_override("font_color", color)

func _on_resetButton_pressed():
	loginOrSignupOrReset = 2
	var userEmail = emailInpt.text
	if emailInpt.text.empty() || (" " in userEmail) == true:
		resetLabelErr("Please enter an E-mail", Color(1, 0, 0))
	else:
		startLoadingAnimation()
		Firebase.Auth.send_password_reset_email(userEmail)

# Function used by both signup and login
func on_FirebaseAuth_login_signup_failed(error_code, message):
	stopLoadingAnimation()
	if loginOrSignupOrReset == 0:
		if error_code == 400:
			loginErrLbl.text = "Invalid E-mail or password"
			loginErrLbl.add_color_override("font_color", Color(1,0,0))
	elif loginOrSignupOrReset == 1:
		if error_code == 400:
			if message == "EMAIL_EXISTS":
				signUpError("Email already exists")
			elif message == "INVALID_EMAIL":
				signUpError("Invalid E-mail")
			elif message == "WEAK_PASSWORD : Password should be at least 6 characters":
				signUpError("Password should contain at least 6 characters")
	elif loginOrSignupOrReset == 2:
		if error_code == 400:
			if message == "INVALID_EMAIL":
				resetLabelErr("Please enter a valid Email", Color(1, 0, 0))
			elif message == "EMAIL_NOT_FOUND":
				resetLabelErr("Email not found. Please register an account.", Color(1,0,0))

func _get_FirebaseAuth_completed_request(result, response_code, headers, body):
	if response_code == 200:
		if $loadingAnimationG1.is_playing() && (loginOrSignupOrReset == 1 || loginOrSignupOrReset == 2):
			stopLoadingAnimation()
		if loginOrSignupOrReset == 1:
			signUpSuccess()
		elif loginOrSignupOrReset == 2:
			resetLabelErr("The password reset link has been sent to your E-mail", Color(0,1,0))
