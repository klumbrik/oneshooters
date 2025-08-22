extends Node2D

var room = preload("res://room.tscn")
@onready var sprite = $CanvasLayer/CenterContainer/ui_weapon

var sprite_angle = 0.0
var body_in_area
var current_bullet
var bullet_ui = preload("res://jebulletui.tscn")

@onready var slot1 = $CanvasLayer/CenterContainer/ui_weapon/slot1
@onready var slot2 = $CanvasLayer/CenterContainer/ui_weapon/slot2
@onready var slot3 = $CanvasLayer/CenterContainer/ui_weapon/slot3
@onready var slot4 = $CanvasLayer/CenterContainer/ui_weapon/slot4
@onready var slot5 = $CanvasLayer/CenterContainer/ui_weapon/slot5
@onready var slot6 = $CanvasLayer/CenterContainer/ui_weapon/slot6

var revolver

func _ready() -> void:
	revolver = {
	1:slot1,
	2:slot2,
	3:slot3,
	4:slot4,
	5:slot5,
	6:slot6
} #slots indexes match their positions
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
	bullet.global_position = revolver[6].global_position
	revolver_reverse_update_indicies()
	
	
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
	revolver_update_indicies()
	#print(revolver)



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
		
	
func _on_enemy_died_in_zone(enemy):
	stash_visibility()

func _used_stash(): #&&&&&&&&??????????????
	if G.stash_pieces == 1:
		$CanvasLayer/CenterContainer/stash1.visible = false
	if G.stash_pieces == 0:
		$CanvasLayer/CenterContainer/stash2.visible = false
		
	#add 3 bullets stash
	var markers = [revolver[1], revolver[2], revolver[3]]
	for marker in markers:
		var bullet = bullet_ui.instantiate()
		$CanvasLayer/CenterContainer/ui_weapon.add_child(bullet)
		bullet.global_position = marker.global_position
		
func revolver_update_indicies():
	var new_slots = {}
	for i in range(1,7):
		var next_index = i % 6 + 1
		new_slots[i] = revolver[next_index] #get link to a slot from revolver + 1
	revolver = new_slots
		
	
func revolver_reverse_update_indicies():
	var new_slots = {}
	for i in range(1, 7):
		var prev_index = (i - 2 + 6) % 6 + 1
		new_slots[i] = revolver[prev_index]
	revolver = new_slots
