extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#code below was here before
	#else: 
		#get_tree().paused = false


func _on_button_down() -> void:
	get_tree().paused = true
	var pause = preload("res://pause.tscn").instantiate()
	get_parent().add_child(pause)
