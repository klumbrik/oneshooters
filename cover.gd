extends Node2D
var used = true #the cover should be used only 1 time
var cover = preload("res://cover.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cover_area_area_entered(area: Area2D) -> void:
	if area.is_in_group('character'):
		if !used:
			used = true #after the character reaches the cover it becomes used
			G.right_swipe_detected = false
			G.moving = false #character stops
			G.score += 50 

func _on_cover_area_area_exited(area: Area2D) -> void:
	if area.is_in_group('character'):
		G.covers_to_spawn = 1# we update new covers to spawn later

		if G.right_swipe_detected:
			print(G.covers_to_spawn)
			if G.covers_to_spawn == 1:
				spawn_new_cover()
				print("cover has been spawned")
				#twice why^&?

func spawn_new_cover():
	G.covers_to_spawn -= 1
	var new_cover = cover.instantiate()
	new_cover.used = false #accesses local used variable and makes all new covers unused
	new_cover.position = Vector2(position.x + get_viewport().size.x + 500, position.y)
	new_cover.show_behind_parent = true
	get_parent().call_deferred("add_child", new_cover) # Use call_deferred to safely add the new cover to the scene tree after the frame has been processed
	
	#will need to change layer just for visuals
