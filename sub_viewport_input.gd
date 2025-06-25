extends Control
var sprite_angle = 0.0
var body_in_area
var current_bullet
@onready var sprite = $CenterContainer/ui_weapon
var bullet_ui = preload("res://jebulletui.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	G.rotate_ui.connect(self._on_ui_rotate)
	G.shot.connect(self._on_shot)
	if G.sound_on:
		$Synthoneshootersdemo4.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_bullet)
	#print(mouse_on_screen)
	pass
	
	
func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event is InputEventMouseButton and event.pressed:
		##print(event, event.global_position)
		#var new_event = event.duplicate() #creating a copy of event for safety
		#$SubViewportContainer/SubViewport.push_input(new_event)

func rotate_60_tween():
	var new_rotation = sprite_angle + 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.4)
	#print(sprite.rotation_degrees)
	var bullet = bullet_ui.instantiate()
	$CenterContainer/ui_weapon.add_child(bullet)
	bullet.global_position = $CenterContainer/Marker2D.global_position
	
func shot_back_rotate_60_tween():
	var new_rotation = sprite_angle - 60.0
	sprite_angle = new_rotation
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees",new_rotation, 0.1)
	#print(sprite.rotation_degrees)
	if body_in_area:
		if is_instance_valid(current_bullet):
			current_bullet.queue_free()
	
func _on_ui_rotate():
	rotate_60_tween()

func _on_shot():
	shot_back_rotate_60_tween()
func _on_area_2d_body_entered(body: Node2D) -> void:
	#print(body)
	body_in_area = true
	current_bullet = body
	#print(current_bullet)


func _on_area_2d_body_exited(body: Node2D) -> void:
	body_in_area = false
