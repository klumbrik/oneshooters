extends Control

var tapped := false
var animation_playing = false

@export var effect_speed: float = 50.0
@export var max_offset: float = 30.0

@onready var bg: Control = $"space"
@onready var chr: Control = $Jedpromo1

var base_bg_pos: Vector2
var base_chr_pos: Vector2

func _ready() -> void:
	if !G.main_menu_already_loaded_first_time: #for bootsplash animation to play only the first time
		G.main_menu_already_loaded_first_time = true
		$SplashTransition/AnimationPlayer.play("fade_out")
	$Label/AnimationPlayer.play("blink")
	base_bg_pos = bg.position
	base_chr_pos = chr.position

func _physics_process(delta: float) -> void:
	var accel3: Vector3 = Input.get_accelerometer()
	if accel3.length() == 0.0:
		return

	var accel2: Vector2 = Vector2(accel3.x, accel3.y).normalized()
	var offset: Vector2 = (accel2 * effect_speed).limit_length(max_offset)

	# Фон
	bg.position = bg.position.lerp(base_bg_pos + offset, 0.1)

	# Персонаж (желаемая позиция)
	var desired_pos: Vector2 = base_chr_pos - offset

	# Сначала lerp
	chr.position = chr.position.lerp(desired_pos, 0.1)

	# 🔒 ЖЁСТКИЙ clamp ПОСЛЕ lerp
	var viewport_bottom: float = get_viewport_rect().size.y
	var chr_global_rect := chr.get_global_rect()
	var chr_bottom: float = chr_global_rect.position.y + chr_global_rect.size.y

	if chr_bottom < viewport_bottom:
		var diff := viewport_bottom - chr_bottom
		chr.position.y += diff


func _input(event: InputEvent) -> void:
	if tapped or animation_playing:
		return

	if event is InputEventScreenTouch and event.pressed:
		tapped = true
		G.emit_signal("menu_play")





#buttons are hidden and not used
func _on_play_button_down() -> void:
	queue_free()
	G.emit_signal("menu_play")


func _on_exit_button_down() -> void:
	get_tree().quit()
