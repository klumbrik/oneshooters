extends RichTextLabel

@export var default_duration: float = 0.4

var is_animating = false
var _displayed: int = 0          # что сейчас видно игроку
var _target: int = 0             # куда хотим докрутить
var _tween: Tween = null
var _last_shown: int = -1    # чтобы тики и апдейты были только при изменении целого

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	text = str(_displayed)
	G.score_changed.connect(_on_score_changed)
	


func animate_to(target: int, duration: float = -1) -> void:
	if duration <= 0:
		duration = default_duration
		
	_target = target
		
	if _displayed == target:
		return
	
	if _tween and _tween.is_running():
		_tween.kill()
		
	_last_shown = _displayed
	is_animating = true
	
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	_tween.tween_method(_update_displayed, float(_displayed), float(_target), duration)
	
	_tween.finished.connect(_on_tween_finished)


func _update_displayed(v: float):
	var next := int(round(v))
	if _target > _displayed:
		next = clamp(next, _displayed, _target)
	else:
		next = clamp(next, _target, _displayed)
		
	if next != _last_shown:
		_last_shown = next
		_displayed = next
		text = str(_displayed)


func _on_tween_finished():
	_displayed = _target
	text = str(_displayed)
	is_animating = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !G.wave_going and !is_animating:
		text = "RUN?"
	else:
		if !is_animating:
			text = str(G.score)



func _on_score_changed(score):
	animate_to(score)
	
