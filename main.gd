extends Node2D
var cover = preload("res://cover.tscn")
#main decreased and changed positions. If any problem occurs change back.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#G.area_res = get_window().get_visible_rect().size #decide which variable is better because they are basically the same with line 17 
	set_things_pos()
	G.character_position = $character.position #global or local? 
	print("character position received:",G.character_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.

		
		


func set_things_pos(): #setting the positions regardless of resolution разберусь 
	var screen_size = get_viewport().get_visible_rect().size #need to check if it changes as I change the window
	#position = Vector2(screen_size.x * 0.1, screen_size.y * 0.5)
	


	
	


func _on_button_button_down() -> void:
	$CanvasLayer/Button.visible = false
	get_tree().paused = false
	G.game_over = false
	G.moving = false
	G.right_swipe_detected = false
	G.ammo = 6
	G.score = 0
	G.stash = 0
	get_tree().reload_current_scene()
	
