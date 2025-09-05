extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_released("press"):
		#print("PLAY")
		#queue_free()
		#G.emit_signal("menu_play")

func _on_play_button_down() -> void:
	queue_free()
	G.emit_signal("menu_play")


func _on_exit_button_down() -> void:
	get_tree().quit()
