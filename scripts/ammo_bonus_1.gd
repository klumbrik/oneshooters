extends RigidBody2D
#this bonus is like stash piece
var converted_to_coin = false
@export var tag: String = "ammo3"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Icon.visible = true
	$Pick_Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("hello")
	#print(tag)
	if tag == "ammo3":
		if G.stash_pieces == 2:
			convert_to_coin()
	if tag == "shield":
		if G.shield_enabled:
			convert_to_coin()
	if tag == "drone":
		if G.drone_active:
			convert_to_coin()

func _on_pick_timer_timeout() -> void:
	$AnimationPlayer.play("dissappear")





func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("character"):
		$AnimationPlayer.play("pick")
		
		if tag == "coin":
			$coin.play() #sound
		
		
			


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pick":
		#print("PIcked")
		if tag == "shield":
			G.shield_enabled = true
		elif tag == "ammo3":
			if G.stash_pieces < 2:
				G.stash_pieces += 1
				G.stash += 3
			G.emit_signal("bonus_stash")
		elif tag == "coin":
			G.coins += 1
		elif tag == "drone":
			G.drone_active = true
		queue_free()

func convert_to_coin():
	tag = "coin"
	if !converted_to_coin:
		$AnimationPlayer.play("to_coin")
		converted_to_coin = true
