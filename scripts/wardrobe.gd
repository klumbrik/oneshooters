extends Control

@onready var skin_name = $CenterContainer2/Label
var animation_playing

var mouse_on_skin2 = false

#NOTE: implement with an array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if G.skin2bought:
		$Skin2/Sprite.texture = load("res://sprites/content_smile-removebg-preview.png")
		$Skin2/Label.text = "Вы уже приобрели радикальный респект.Респект."
		hide_price()
	skin_name.text = "Jed"
	animation_playing = false
	
	


func _on_arrow_button_r_button_up() -> void:
	$impact.play()
	print("changing")
	var tween = create_tween()
	var skin1 = $Skin1
	var skin2 = $Skin2
	tween.set_parallel()
	tween.tween_property(skin1, "position", Vector2(-150, 340), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(skin2, "position", Vector2(190, 332), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	skin_name.text = "Respect"
func _on_arrow_button_l_button_up() -> void:
	$impact.play()
	print("changing")
	var tween = create_tween()
	var skin1 = $Skin1
	var skin2 = $Skin2
	tween.set_parallel()
	tween.tween_property(skin1, "position", Vector2(184, 340), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(skin2, "position", Vector2(500, 332), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	skin_name.text = "Jed"


func _on_exit_button_button_up() -> void:
	if !animation_playing:
		G.emit_signal("menu_play")
	






func _on_invisible_button_button_up() -> void:
	
	if G.skin2bought:
		return
	var new_texture = load("res://sprites/content_smile-removebg-preview.png")
	var sprite = $Skin2/Sprite
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if G.coins >= 80:
		$buy.play()
		sprite.texture = new_texture
		$Skin2/Label.text = "Вы приобрели радикальный респект"
		G.skin2bought = true
		G.coins -= 80
		hide_price()
		G.save_json_file()
		
	else:
		$Skin2/Label.text = "Недостаточно монет"
	
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func hide_price():
	$Skin2/CenterContainer2.visible = false
	$Skin2/CenterContainer3.visible = false
