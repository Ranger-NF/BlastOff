shader_type canvas_item;

// --- Uniforms --- //
uniform float cutout: hint_range(0.0, 1.0, 0.01) = 0.20;
uniform float inner_fill: hint_range(0.0, 1.0, 0.01) = 0.15;

uniform float blink_speed: hint_range(0.0, 10.0, 0.1) = 2.0;

// --- Functions --- //
void fragment() {
	float dist = distance(UV, vec2(0.5));
	COLOR.a *= 1.0 - step(0.5, dist);
	COLOR.a += step(0.5 - cutout / 2.0, dist);
	COLOR.a -= step((0.5 - (cutout + inner_fill) / 2.0) * step(0.5, mod(TIME * blink_speed, 1.0)), dist);
}
