extends Node2D
@onready var area: Vector2 = get_window().get_visible_rect().size
var Fire_Target_Visual = preload("res://Fire_Target_Visual.tscn")
# Called when the node enters the scene tree for the first time.

var current_target: Node2D = null  # Stores a reference to the spawned instance in order to be able to remove it later

func _ready() -> void:
	G.enemy_died.connect(self._on_enemy_died)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(area)
	pass
func spawn():	
	remove()
	#print(G.character_position.y , "is y pos")
	var random_x = randf_range(G.character_position.x + 100, area.x) #create a random x position for the target
	var pos_y = G.character_position.y 
	current_target = Fire_Target_Visual.instantiate()
	current_target.global_position = Vector2(random_x, pos_y)
	get_parent().call_deferred("add_child", current_target) # Use call_deferred to safely add the new cover to the scene tree after the frame has been processed

func remove():
	if is_instance_valid(current_target): #if exists
		current_target.call_deferred("queue_free")

func _on_hot_target_timer_timeout() -> void:
	if G.character_position != Vector2.ZERO: #if the character pos is received early it may be zero which we don't want (though timer allows to avoid it)
		spawn()

func _on_enemy_died():
	print("he is defeated")
	remove()
