extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if G.game_over == true:
		visible = true
		text = """Play again. Your score is %s
		Best score: %s""" % [G.score, G.best_score]
	else:
		visible = false
		
	_update_audio_effect()


func _on_button_down() -> void: #restore EVERYTHING HERE
	if G.score >= G.best_score:
		G.best_score = G.score #saving new best
	
	G.stash = 0
	G.score = 0
	G.game_over = false
	G.current_cover_number = 0
	G.last_cover_number = -1
	G.number_of_dodges = 1
	get_tree().paused = false
	G.emit_signal("reload_game")
	G.enemiesonscreen.clear()
	G.rooms.clear()



func _update_audio_effect() -> void: #change kostyl later
	var eq_bus := AudioServer.get_bus_index("Music")
	if visible:
		AudioServer.set_bus_effect_enabled(eq_bus, 0, true)  # Включить EQ
	else:
		AudioServer.set_bus_effect_enabled(eq_bus, 0, false) # Выключить EQ
