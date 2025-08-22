extends CharacterBody2D


func _ready() -> void:
	$AnimationPlayer.play("load")


func unload():
	$AnimationPlayer.play("unload")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "unload":
		queue_free()
