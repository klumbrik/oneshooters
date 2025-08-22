extends Node2D

var room = preload("res://room.tscn")
@onready var sprite = $CanvasLayer/CenterContainer/ui_weapon

var sprite_angle = 0.0
var body_in_area
var current_bullet
var bullet_ui = preload("res://jebulletui.tscn")

func _ready() -> void:
	await get_tree().process_frame #to not get null when adding the first room to array
	G.rooms.clear()
	G.rooms.append($room) #adding the first room to array
	G.swipe_room.connect(self._create_room_on_swipe)
	G.rotate_ui.connect(self._on_ui_rotate)
	G.shot.connect(self._on_shot)
	G.enemy_died_in_zone.connect(self._on_enemy_died_in_zone)
	G.out_of_ammo.connect(self._used_stash)
	
	
func rotate_60_tween():
	var new_rotation = sprite_angle + 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.4)
	#print(sprite.rotation_degrees)
	var bullet = bullet_ui.instantiate()
	$CanvasLayer/CenterContainer/ui_weapon.add_child(bullet)
	bullet.global_position = $CanvasLayer/CenterContainer/Marker2D.global_position
	
func shot_back_rotate_60_tween():
	var new_rotation = sprite_angle - 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.1)
	#print(sprite.rotation_degrees)
	if body_in_area:
		if is_instance_valid(current_bullet):
			current_bullet.unload()
	
func _on_ui_rotate():
	rotate_60_tween()

func _on_shot():
	shot_back_rotate_60_tween()



func _on_area_2d_body_entered(body: Node2D) -> void:
	#print(body)
	body_in_area = true
	current_bullet = body
	#print(current_bullet)


func _on_area_2d_body_exited(body: Node2D) -> void:
	body_in_area = false




func _create_room_on_swipe():
	var previous_room = G.rooms[-1]
	#print("room created")
	var next_room = room.instantiate()
	add_child(next_room)
	next_room.global_position.x = previous_room.position.x + 360
		
	#adding the new room
	G.rooms.append(next_room) 

	#removing rooms
	if G.rooms.size() > 2: #2 for safety but can be 1
		var old_room = G.rooms[0]
		if is_instance_valid(old_room):
			old_room.queue_free()
		G.rooms.remove_at(0)
		
	#print(G.rooms)
	
func stash_visibility():
	if G.stash_pieces == 1:
		$CanvasLayer/CenterContainer/stash2.visible = true
	if G.stash_pieces > 1:
		$CanvasLayer/CenterContainer/stash1.visible = true
		
	
func _on_enemy_died_in_zone():
	stash_visibility()

func _used_stash(): #&&&&&&&&??????????????
	if G.stash_pieces == 1:
		$CanvasLayer/CenterContainer/stash1.visible = false
	if G.stash_pieces == 0:
		$CanvasLayer/CenterContainer/stash2.visible = false
