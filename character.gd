extends CharacterBody2D

var is_shooting = true
var ammo = 6
var bullet = preload("res://bullet.tscn")

func _ready() -> void:
	$Sprite2D/AnimationPlayer.play("shoot")
	$Timer.start()
	

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			$Sprite2D/AnimationPlayer.play("duck")
			is_shooting = false
			$ReloadTimer.start()
		else:
			$Sprite2D/AnimationPlayer.play("shoot")
			is_shooting = true
			$ReloadTimer.stop()
			
		
func _physics_process(_delta: float) -> void:
	G.ammo = ammo
	if !is_shooting:
		$Timer.paused = true
	else:
		$Timer.paused = false
	
	


func _on_timer_timeout() -> void:
	if ammo > 0:
		var new_bullet = bullet.instantiate()
		add_child(new_bullet)
		ammo -= 1


func _on_reload_timer_timeout() -> void:
	if ammo < 6:
		ammo += 1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies'):
		get_tree().paused = true


func _on_shootingrange_body_exited(body: Node2D) -> void: #bullet range restriction
	if body.is_in_group("damage"):
		body.queue_free()
