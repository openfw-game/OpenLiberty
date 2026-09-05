class_name RWTextureDict
extends Resource

@export var textures: Dictionary[String, Texture2D] = { }


func get_texture(name: String) -> Texture2D:
	var normalized_name := name.to_lower()
	for texture_name in textures:
		if texture_name.to_lower() == normalized_name:
			return textures[texture_name]
	return null
