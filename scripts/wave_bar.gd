extends TextureProgressBar

func _ready() -> void:
	min_value = 0
	max_value = 100
	value = 0

func _process(delta: float) -> void:
	# обновляем значение бара
	value = G.break_bar_progress * max_value

	# нормализуем 0..1 для шейдера
	var progress := value / max_value

	# прокидываем в ShaderMaterial
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("progress", progress)
