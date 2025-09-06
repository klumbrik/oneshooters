extends TextureProgressBar

var tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	G.connect("dodge_bar_empty", _empty_bar)
	G.connect("dodge_bar_fill", _fill_bar)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#check for bugs?
func _empty_bar():
	if tween:
		tween.kill() # kill last tween if existed
	tween = create_tween()
	tween.tween_property(self, "value", 0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
func _fill_bar():
	if tween:
		tween.kill() # kill last tween if existed
	tween = create_tween()
	tween.tween_property(self, "value", 100, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
