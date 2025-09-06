extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	G.enemy_died_in_zone.connect(self._on_enemy_died_in_zone)


func _on_enemy_died_in_zone(enemy):
	var parent = get_parent()
	if enemy == parent: #checking if the parent of this effect is the enemy instance passed, so that fx plays only on it
		visible = true
		if enemy.coin_given:
			$position_anim/RichTextLabel.text = "+Монета"
			$position_anim/AnimationPlayerShot.play("coin")
		else:
			$position_anim/RichTextLabel.text = "Идеально"
			$position_anim/AnimationPlayerShot.play("perfect")
		
