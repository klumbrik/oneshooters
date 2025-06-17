extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#print(mouse_on_screen)
	
	


func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event is InputEventMouseButton and event.pressed:
		##print(event, event.global_position)
		#var new_event = event.duplicate() #creating a copy of event for safety
		#$SubViewportContainer/SubViewport.push_input(new_event)
