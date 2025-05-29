extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if G.game_over == true:
		visible = true
	else:
		visible = false


func _on_button_down() -> void:
	G.game_over = false
	get_tree().paused = false
	G.get_tree().change_scene_to_file("res://main.tscn") #reloading the smae scene
	G.enemiesonscreen.clear()
