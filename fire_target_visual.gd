extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(G.is_enemy_in_zone)
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		G.is_enemy_in_zone = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		G.is_enemy_in_zone = false


	
