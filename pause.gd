extends Control

@onready var text_loc = $VBoxContainer/sound/CenterContainer/soundLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$impact.play()
	if G.sound_on:
		text_loc.text = "sound: on"
	else:
		text_loc.text = "sound: off"
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
	$impact.play()
	if toggled_on:
		text_loc.text = "sound: on"
		G.sound_on = true
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
		
	else:
		text_loc.text = "sound: off"
		G.sound_on = false
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)
