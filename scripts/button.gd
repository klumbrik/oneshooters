extends Button
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#visible = true
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if G.game_over == true:
		#visible = true
		#text = """Play again. Your score is %s
		#Best score: %s""" % [G.score, G.best_score]
	#else:
		#visible = false
		#
	#_update_audio_effect()
#
#
#
#func _update_audio_effect() -> void: #change kostyl later
	#var eq_bus := AudioServer.get_bus_index("Music")
	#if visible:
		#AudioServer.set_bus_effect_enabled(eq_bus, 0, true)  # Включить EQ
	#else:
		#AudioServer.set_bus_effect_enabled(eq_bus, 0, false) # Выключить EQ
