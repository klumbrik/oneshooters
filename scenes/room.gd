extends Node2D
class_name Room

var spawner: HotTargetSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawner = $Hot_Target_Spawner
