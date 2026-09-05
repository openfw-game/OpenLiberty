shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform sampler2D texture : source_color, hint_default_white;
uniform sampler2D mask;
uniform bool modulate = true;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);

uniform bool prelit = false;

void fragment() {
	vec3 base_color = texture(texture, UV).rgb;
	if (modulate) {
		base_color *= color;
	}
	if (prelit) {
		base_color *= COLOR.rgb;
	}
	ALBEDO = base_color;
	ALPHA = texture(mask, UV).r;
}
