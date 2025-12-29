extends "res://scripts/ammo_bonus_1.gd"
#LAYER AND MASK FOR BONUSES AND FLOOR IS 24

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.visible = true
	$Pick_Timer.start()
	tag = "shield"


# Called every frame. 'delta' is the elapsed time since the previous frame.
