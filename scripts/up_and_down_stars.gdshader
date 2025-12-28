shader_type canvas_item;

uniform float x_amplitude = 1;
uniform float y_amplitude = 0.3;
uniform float speed = 0.02;

float smooth_sin(float t) {
	float s = sin(t);
	return s * s * sign(s);
}

void fragment() {
	vec2 uv = UV;

	float t = TIME * speed;

	// более плавный маятник
	float x_motion = smooth_sin(t);
 
	uv.x += x_motion * x_amplitude;
	uv.y += sin(t * 2.0) * y_amplitude;

	COLOR = texture(TEXTURE, uv);
}
