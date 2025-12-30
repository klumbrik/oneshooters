shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float overlay_strength : hint_range(0.0, 1.0) = 0.9;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	// маска заполнения (From Center + Bilinear L/R)
	float dist = abs(UV.x - 0.5) * 2.0;
	float fill_mask = step(dist, progress);
	base.a *= fill_mask;

	// ---------- ЦВЕТОВАЯ ЛОГИКА ----------
	vec3 yellow = vec3(1.0, 0.9, 0.2);
	vec3 orange = vec3(1.0, 0.5, 0.1);
	vec3 red    = vec3(1.0, 0.15, 0.1);

	vec3 overlay = vec3(0.0);
	float strength = 0.0;

	if (progress <= 0.7 && progress > 0.5) {
		// 70% → 50% : желтый → оранжевый
		float t = (0.7 - progress) / 0.2;
		overlay = mix(yellow, orange, t);
		strength = t;
	}
	else if (progress <= 0.5 && progress > 0.3) {
		// 50% → 30% : оранжевый → красный
		float t = (0.5 - progress) / 0.2;
		overlay = mix(orange, red, t);
		strength = 0.6 + t * 0.4;
	}
	else if (progress <= 0.3) {
		// < 30% : максимально красный
		overlay = red;
		strength = 1.0;
	}

	// накладываем цвет поверх оригинальной текстуры
	base.rgb = mix(base.rgb, overlay, strength * overlay_strength);

	COLOR = base;
}
