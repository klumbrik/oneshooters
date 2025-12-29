extends TextureProgressBar


func _ready() -> void:
	value = 0
func _process(delta: float) -> void:
	value = G.break_bar_progress * 100 
