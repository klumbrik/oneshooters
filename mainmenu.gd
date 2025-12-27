extends Control

var tapped := false
var animation_playing = false

@export var effect_speed: float = 50.0
@export var max_offset: float = 30.0   # ограничение амплитуды

@onready var bg := $"706Ed7a3a5Eb8f7e4Bd227188Cff51d1"
@onready var chr := $Jedpromo1

var base_bg_pos: Vector2
var base_chr_pos: Vector2

func _ready() -> void:
	$Label/AnimationPlayer.play("blink")
	base_bg_pos = bg.position
	base_chr_pos = chr.position
	
func _physics_process(delta: float) -> void:
	var accel3: Vector3 = Input.get_accelerometer()
	if accel3.length() == 0.0:
		return  # на десктопе часто будет ноль

	# Преобразуем в 2D. Для портрета: x вправо, y вверх (можешь инвертировать по вкусу).
	var accel2: Vector2 = Vector2(accel3.x, accel3.y).normalized()

	# Амплитуда смещения (ограничиваем, чтобы не «уплывало» слишком далеко)
	var offset := accel2 * effect_speed
	offset = offset.limit_length(max_offset)

	# Фон слегка уходит в сторону наклона...
	bg.position = bg.position.lerp(base_bg_pos + offset, 0.1)
	# ...а персонаж — в противоположную
	chr.position = chr.position.lerp(base_chr_pos - offset, 0.1)
func _input(event: InputEvent) -> void:
	if tapped or animation_playing:
		return

	if event is InputEventScreenTouch and event.pressed:
		tapped = true
		print("Tap detected, starting game")
		G.emit_signal("menu_play")
		#queue_free()










#buttons are hidden and not used
func _on_play_button_down() -> void:
	queue_free()
	G.emit_signal("menu_play")


func _on_exit_button_down() -> void:
	get_tree().quit()
