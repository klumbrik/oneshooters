extends Node2D

var room = preload("res://room.tscn")

func _ready() -> void:
	await get_tree().process_frame #to not get null when adding the first room to array
	G.rooms.clear()
	G.rooms.append($room) #adding the first room to array
	G.swipe_room.connect(self._create_room_on_swipe)

func _on_child_entered_tree(node: Node) -> void: #when the first room enters the tree, we add it to the array
	pass

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
		
