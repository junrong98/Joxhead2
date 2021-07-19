extends Button

export(String) var action_name = ""

var do_set = false

func _pressed():
	text = "Pressed any key"
	do_set = true
	
func _input(event):
	if(do_set):
		if(event is InputEventKey):
			# Remove the old keys
			var newkey = InputEventKey.new()
			newkey.scancode = int(ControlScript.key_dict[action_name])
			InputMap.action_erase_event(action_name,newkey)
			# Add the new key for this action
			InputMap.action_add_event(action_name,event)
			# Show it as readable to the user
			text = OS.get_scancode_string(event.scancode)
			# Update the keydictionary with the scanscode to save
			ControlScript.key_dict[action_name] = event.scancode
			# Save the dictionary to json
			ControlScript.save_keys()
			# Stop setting the key
			do_set = false
