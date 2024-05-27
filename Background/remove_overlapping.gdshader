shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
  vec4 tex = texture(TEXTURE, UV);
  COLOR = vec4(mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, tex.rgb - (1.-MODULATE.rgb), MODULATE.a), tex.a);
}