extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if G.sound_on:
		$VBoxContainer/sound.text = "sound: ON"
	else:
		$VBoxContainer/sound.text = "sound: OFF"
		$VBoxContainer/sound.button_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_down() -> void:
	#print("hi")
	get_tree().paused = false
	queue_free()
	G.pause_added = false


func _on_to_menu_button_down() -> void:
	get_tree().paused = false
	G.emit_signal("pause_menu")
	queue_free()


func _on_sound_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VBoxContainer/sound.text = "sound: ON"
		G.sound_on = true
	else:
		$VBoxContainer/sound.text = "sound: OFF"
		G.sound_on = false
