extends "res://scripts/ammo_bonus_1.gd"

signal picked #for tutorial
@onready var timer = $Pick_Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if G.tutorial_mode:
		$Pick_Timer.stop()
	$Icon.visible = true
	$Pick_Timer.start()
	tag = "drone"


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "pick" and G.tutorial_mode:
		emit_signal("picked")
