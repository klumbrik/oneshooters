extends Control

@onready var skin_name = $CenterContainer2/Label
var animation_playing

var mouse_on_skin2 = false

var skin2price = 200
#NOTE: implement with an array
var skin_status_labels = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if G.skin2bought:
		$Skin2/Sprite.texture = load("res://sprites/Jedanims/Snowman/snowmanshoot/snowmanshoot1.png")
		$Skin2/Label.text = "-CLICK TO EQUIP-"
		hide_price()
	else:
		$Skin2/Sprite.texture = load("res://snowman_black_white.png")
		$Skin2/Label.text = "-CLICK TO BUY-"
	skin_name.text = "Jed"
	animation_playing = false
	skin_status_labels.append($Skin1/Label)
	skin_status_labels.append($Skin2/Label)
	match G.current_skin:
		"default":
			$Skin1/Label.text = "*EQUIPPED*"
		"snowman":
			$Skin2/Label.text = "*EQUIPPED*"
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("left"):
		_on_arrow_button_l_button_up()
	elif Input.is_action_just_released("right"):
		_on_arrow_button_r_button_up()
func _on_arrow_button_r_button_up() -> void:
	$impact.play()
	print("changing")
	var tween = create_tween()
	var skin1 = $Skin1
	var skin2 = $Skin2
	tween.set_parallel()
	tween.tween_property(skin1, "position", Vector2(-150, 340), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(skin2, "position", Vector2(190, 332), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	skin_name.text = "Snowman"
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
	var sprite = $Skin2/Sprite
	
	if equip_skin(G.skin2bought, sprite, $Skin2/Label, "snowman"):
		return
	
	if G.skin2bought:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(8, 8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		$Skin2/Label.text = "*EQUIPPED*"
		tween.tween_property(sprite, "scale", Vector2(10, 10), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	
	var new_texture = load("res://sprites/Jedanims/Snowman/snowmanshoot/snowmanshoot1.png")
	var tween = create_tween()
	
	tween.tween_property(sprite, "scale", Vector2(8, 8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if G.coins >= skin2price:
		$buy.play()
		sprite.texture = new_texture
		$Skin2/Label.text = "BOUGHT. CLICK TO EQUIP."
		G.skin2bought = true
		G.coins -= skin2price
		hide_price()
		G.save_json_file()
		
	else:
		$Skin2/Label.text = "NOT ENOUGH COINS"
	
	tween.tween_property(sprite, "scale", Vector2(10, 10), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func hide_price():
	$Skin2/CenterContainer2.visible = false
	$Skin2/CenterContainer3.visible = false
	

func _on_invisible_button_default_button_up() -> void:
	var sprite = $Skin1/Sprite
	var default_skin_bought = true
	if equip_skin(default_skin_bought, sprite, $Skin1/Label, "default"): 
		return



func equip_skin(skin_bought, sprite, label, skin_name):
	if skin_bought:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(8, 8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		label.text = "*EQUIPPED*"
		
		$reload.play()
		G.set_skin(skin_name)  
		G.save_json_file()
		
		var this_label_index = skin_status_labels.find(label)
		for i in range(0, skin_status_labels.size()):
			if skin_status_labels[i] is Label and skin_status_labels[i].text == "*EQUIPPED*" and i != this_label_index:
				skin_status_labels[i].text = "-CLICK TO EQUIP-"
		tween.tween_property(sprite, "scale", Vector2(10, 10), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		return true
	else:
		return false
		print("can't equip skin")
