extends Node2D
class_name Score_effect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/AnimationPlayer.play("appear")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func set_score_amount(text:int):
	$Control/score_added_ux.text = "+" + str(text)

func play_y_anim():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"position:y",
		position.y - 12.5,
		0.4
	)

	tween.finished.connect(queue_free)
