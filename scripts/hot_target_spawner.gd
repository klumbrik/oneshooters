extends Node2D

class_name HotTargetSpawner

#@onready var area: Vector2 = get_window().get_visible_rect().size 
@onready var collision = get_parent().get_node("StaticBody2D/CollisionShape2D")
@onready var shape = collision.shape as RectangleShape2D
@onready var size = shape.extents * 2
@onready var origin = collision.global_position - shape.extents
@onready var room_rect := Rect2(origin, size)


var Fire_Target_Visual = preload("res://scenes/Fire_Target_Visual.tscn")
# Called when the node enters the scene tree for the first time.

var current_target: Node2D = null  # Stores a reference to the spawned instance in order to be able to remove it later
@onready var disabled = false
@onready var parent_room = get_parent()

const MIN_DISTANCE = 40.0

func _ready() -> void:
	if G.tutorial_mode:
		disabled = true
	if disabled:
		return
	G.enemy_died_in_zone.connect(self._on_enemy_died_in_zone)
	G.delete_enemies_out_of_screen.connect(self._deactivate)
	if G.tutorial_finished:
		spawn()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(area)
	#print(G.rooms)
	pass
func spawn():	
	if disabled:
		return
	remove()
	#print(G.character_position.y , "is y pos")
	#var random_x = area.x- 100 #substract some pixels so it's closer to the player
	var random_x = randf_range(G.character_position.x + 90, room_rect.position.x + room_rect.size.x - 100) #create a random x position for the target #substract some pixels from area.x so that it's closer to the player
	var pos_y = G.character_position.y + 28
	
	if current_target != null and abs(random_x - current_target.global_position.x) < MIN_DISTANCE:
		random_x += MIN_DISTANCE * sign(random_x - current_target.global_position.x)
		random_x = clamp(random_x, G.character_position.x + 90, room_rect.position.x + room_rect.size.x - 100)
		
	if !disabled: #add again only if not disabled
		current_target = Fire_Target_Visual.instantiate()
		current_target.global_position = Vector2(random_x, pos_y)
		get_parent().call_deferred("add_child", current_target) # Use call_deferred to safely add the new cover to the scene tree after the frame has been processed

func remove():
	if is_instance_valid(current_target): #if exists
		current_target.call_deferred("queue_free")

func _on_hot_target_timer_timeout() -> void:
	if disabled:
		return
	if G.character_position != Vector2.ZERO: #if the character pos is received early it may be zero which we don't want (though timer allows to avoid it)
		if G.tutorial_finished:
			spawn()

func _on_enemy_died_in_zone(enemy):
	#print("he is defeated")
	remove()
	
func _deactivate(): #called when new cover/room reached; spawner gets deactivated
	pass
	#if G.rooms.size() > 0:
		#if G.rooms[0] == parent_room and !G.rooms.size() == 1:
			#disabled = true
