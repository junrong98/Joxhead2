extends CPUParticles2D

# Temporary show the blood stain and disaapear after certain timing
func _on_Freeze_Blood_timeout():
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
