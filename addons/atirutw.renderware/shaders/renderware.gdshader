shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;

uniform sampler2D texture : source_color, hint_default_white;
uniform sampler2D mask;
uniform bool modulate = true;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);

uniform bool prelit = false;
// Ambient is actually ignored; Godot provides ambient lighting
uniform float ambient : hint_range(0, 1) = 1.0;
uniform float specular : hint_range(0, 1) = 0.0;
uniform float diffuse : hint_range(0, 1) = 1.0;

void fragment() {
    vec3 base_color = texture(texture, UV).rgb;
	if (modulate) {
		base_color *= color;
	}
	ALBEDO = base_color;
	ALPHA = texture(mask, UV).r;

	ROUGHNESS = 1.0 - specular;
	if (prelit) {
		EMISSION = COLOR.rgb * base_color;
	}
}

void light() {
    if (LIGHT_IS_AREA) {
        // Area light GGX shading.
        DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * ATTENUATION * LIGHT_COLOR;
        SPECULAR_LIGHT += LIGHT_AREA_SPECULAR_MULTIPLIER * ATTENUATION * LIGHT_COLOR * SPECULAR_AMOUNT;
    } else {
        // Used for all other light types (directional, omni, spot).
        vec3 light_contrib = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
        DIFFUSE_LIGHT += light_contrib * diffuse;
    }
}
