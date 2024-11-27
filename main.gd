extends Node2D
var cover = preload("res://cover.tscn")
var covers_to_spawn = 1 #how many covers we need to spawn (or don't need) 
#main decreased and changed positions. If any problem occurs change back.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_things_pos()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if G.moving:
		spawn_new_cover()
		
		


func set_things_pos(): #setting the positions regardless of resolution разберусь 
	var screen_size = get_viewport().get_visible_rect().size
	#position = Vector2(screen_size.x * 0.1, screen_size.y * 0.5)
	
func spawn_new_cover():
	var new_cover = cover.instantiate()
	new_cover.global_position = Vector2($Cover.position.x + get_viewport().size.x + 500, $Cover.position.y)
	add_child(new_cover)
	
