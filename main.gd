extends Node2D
var cover = preload("res://cover.tscn")
#main decreased and changed positions. If any problem occurs change back.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_things_pos()


# Called every frame. 'delta' is the elapsed time since the previous frame.

		
		


func set_things_pos(): #setting the positions regardless of resolution разберусь 
	var screen_size = get_viewport().get_visible_rect().size
	#position = Vector2(screen_size.x * 0.1, screen_size.y * 0.5)
	


	
	
