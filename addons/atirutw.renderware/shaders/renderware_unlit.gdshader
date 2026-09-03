shader_type spatial;
render_mode unlit;

uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
uniform bool modulate = true;
uniform sampler2D texture : source_color, hint_default_white;
uniform sampler2D mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec3 base_color = texture(texture, UV).rgb;
	if (modulate) {
		base_color *= color;
	}
	ALBEDO = base_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
