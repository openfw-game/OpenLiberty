@tool
class_name RWMaterial
extends ShaderMaterial

enum BlendMode {
	MIX,
	ADD,
}

const RW_SHADER: Shader = preload("res://addons/atirutw.renderware/shaders/renderware.gdshader")
const RW_ADDITIVE_SHADER: Shader = preload("res://addons/atirutw.renderware/shaders/renderware_additive.gdshader")
const RW_UNLIT_SHADER: Shader = preload("res://addons/atirutw.renderware/shaders/renderware_unlit.gdshader")

@export var texture: Texture2D:
	set(value):
		texture = value
		set_shader_parameter("texture", texture)

@export var mask: Texture2D:
	set(value):
		mask = value
		set_shader_parameter("mask", mask)

@export var modulate: bool = false:
	set(value):
		modulate = value
		set_shader_parameter("modulate", modulate)
		notify_property_list_changed()

@export var color: Color = Color(1, 1, 1):
	set(value):
		color = value
		set_shader_parameter("color", color)

@export_group("Lighting")
@export var blend_mode: BlendMode = BlendMode.MIX:
	set(value):
		blend_mode = value
		_update_shader()
		notify_property_list_changed()

@export var prelit: bool = false:
	set(value):
		prelit = value
		set_shader_parameter("prelit", prelit)

@export var lit: bool = true:
	set(value):
		lit = value
		_update_shader()
		notify_property_list_changed()

@export_range(0, 1) var ambient: float = 1:
	set(value):
		ambient = value
		if lit and blend_mode != BlendMode.ADD:
			set_shader_parameter("ambient", ambient)

@export_range(0, 1) var specular: float = 0:
	set(value):
		specular = value
		if lit and blend_mode != BlendMode.ADD:
			set_shader_parameter("specular", specular)

@export_range(0, 1) var diffuse: float = 1:
	set(value):
		diffuse = value
		if lit and blend_mode != BlendMode.ADD:
			set_shader_parameter("diffuse", diffuse)

@export_group("RenderWare Metadata")
@export var texture_name: String = "":
	set(value):
		texture_name = value
		set_meta("texture_name", value)

@export var mask_name: String = "":
	set(value):
		mask_name = value
		set_meta("mask_name", value)


func _init() -> void:
	_update_shader()


func _update_shader() -> void:
	var target_shader: Shader
	if blend_mode == BlendMode.ADD:
		target_shader = RW_ADDITIVE_SHADER
	elif lit:
		target_shader = RW_SHADER
	else:
		target_shader = RW_UNLIT_SHADER

	if shader != target_shader:
		shader = target_shader

	_sync_parameters()


func _sync_parameters() -> void:
	set_shader_parameter("texture", texture)
	set_shader_parameter("mask", mask)
	set_shader_parameter("modulate", modulate)
	set_shader_parameter("color", color)
	set_shader_parameter("prelit", prelit)

	if lit and blend_mode != BlendMode.ADD:
		set_shader_parameter("ambient", ambient)
		set_shader_parameter("specular", specular)
		set_shader_parameter("diffuse", diffuse)


func _validate_property(property: Dictionary) -> void:
	if property.name == "color" and !modulate:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "lit" and blend_mode == BlendMode.ADD:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	var is_lighting_relevant := (lit and blend_mode != BlendMode.ADD)
	if property.name in ["ambient", "specular", "diffuse"] and !is_lighting_relevant:
		property.usage = PROPERTY_USAGE_NO_EDITOR
