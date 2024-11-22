extends Node2D
var enemy = preload("res://enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Timer.wait_time = randf_range(1, 3) #random time between spawns


func _on_timer_timeout() -> void:
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
