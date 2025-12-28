shader_type canvas_item;

uniform float x_amplitude = 0.07; // горизонтальный размах
uniform float y_amplitude = 0.05; // вертикальное покачивание
uniform float speed = 0.3;        // общая скорость

void fragment() {
	vec2 uv = UV;

	// Основное движение: вправо -> влево (маятник)
	float x_motion = sin(TIME * speed);

	// Горизонтальное смещение
	uv.x += x_motion * x_amplitude;

	// Вертикальное покачивание, зависящее от X-фазы
	// (важно: не самостоятельное!)
	uv.y += sin(TIME * speed * 2.0) * y_amplitude;

	COLOR = texture(TEXTURE, uv);
}
