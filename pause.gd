extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_down() -> void:
	print("hi")
	get_tree().paused = false
	queue_free()


func _on_to_menu_button_down() -> void:
	get_tree().paused = false
	G.emit_signal("pause_menu")
	queue_free()
