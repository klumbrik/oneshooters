extends Node2D

var go_bullet = false # a variable to shoot when anim is finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	G.enemy_shoots.connect(self._enemy_shoots)


func _enemy_shoots(enemy): #called in a parent scene
	if get_parent() == enemy: #so that the animation works only for one
		visible = true
		$position_anim/AnimationPlayer.play("shoot_sign")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot_sign":
		go_bullet = true
