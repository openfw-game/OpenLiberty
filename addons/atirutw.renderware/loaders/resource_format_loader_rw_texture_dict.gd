class_name ResourceFormatLoaderRWTextureDict
extends ResourceFormatLoader

enum {
	D3D8 = 8,
	D3D9 = 9,
}

enum {
	FORMAT_DEFAULT = 0x0000,
	FORMAT_1555 = 0x0100,
	FORMAT_565 = 0x0200,
	FORMAT_4444 = 0x0300,
	FORMAT_LUM8 = 0x0400,
	FORMAT_8888 = 0x0500,
	FORMAT_888 = 0x0600,
	FORMAT_555 = 0x0A00,
	FORMAT_EXT_AUTO_MIPMAP = 0x1000,
	FORMAT_EXT_PAL8 = 0x2000,
	FORMAT_EXT_PAL4 = 0x4000,
	FORMAT_EXT_MIPMAP = 0x8000,
}


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["txd"])


func _handles_type(type: StringName) -> bool:
	return type == &"Resource"


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var chunk := RWChunk.open(path)
	if chunk == null:
		return ERR_FILE_NOT_FOUND

	var texture_dict := _read_texture_dict(chunk)
	if texture_dict == null:
		return ERR_INVALID_DATA
	return texture_dict


func _read_texture_dict(rw_texture_dict: RWChunk) -> RWTextureDict:
	if !rw_texture_dict.expect(RWChunk.TEXTURE_DICTIONARY):
		return null
	var struct := rw_texture_dict.get_struct_stream()
	if struct == null or struct.get_available_bytes() < 4:
		return null

	var num_texs: int = 0
	if rw_texture_dict.version < 0x36000:
		num_texs = struct.get_u32()
	else:
		num_texs = struct.get_u16()
		struct.get_u16() # Dictionary device ID, not the native raster platform ID.

	var texture_dict := RWTextureDict.new()

	var children := rw_texture_dict.get_children()
	if children.size() < num_texs + 1:
		return null
	for i in num_texs:
		var rw_raster: RWChunk = children.get(1 + i)
		if rw_raster == null:
			return null
		if !rw_raster.expect(RWChunk.RASTER):
			return null
		var raster_struct := rw_raster.get_struct_stream()
		if raster_struct == null or raster_struct.get_available_bytes() < 88:
			return null

		var platform_id := raster_struct.get_u32()
		if platform_id != D3D8 and platform_id != D3D9:
			push_error("Unsupported native raster platform: %d" % platform_id)
			return null
		raster_struct.get_32() # Filter mode, U/V addressing, and padding
		var texture_name := raster_struct.get_string(32)
		raster_struct.get_data(32) # Mask name; usually overridden by materials

		var raster_fmt := raster_struct.get_u32()
		var format_or_alpha := raster_struct.get_u32()
		var width := raster_struct.get_u16()
		var height := raster_struct.get_u16()
		var depth := raster_struct.get_u8()
		var num_levels := raster_struct.get_u8()
		raster_struct.get_u8() # Raster type.
		var flags := raster_struct.get_u8()

		var image := _read_raster_image(raster_struct, width, height, depth, num_levels, raster_fmt, platform_id, format_or_alpha, flags)
		if image == null:
			push_error("Could not decode raster: %s" % texture_name)
			return null
		var texture := ImageTexture.create_from_image(image)
		texture_dict.textures[texture_name] = texture

	return texture_dict


static func _get_sizeof_color(fmt: int, depth: int) -> int:
	match fmt & 0x0f00:
		FORMAT_DEFAULT:
			match depth:
				32: return 4
				24: return 3
				16: return 2
				8, 4: return 1
				_: return 0
		FORMAT_1555:
			return 2
		FORMAT_565:
			return 2
		FORMAT_4444:
			return 2
		FORMAT_LUM8:
			return 1
		FORMAT_8888:
			return 4
		FORMAT_888:
			return 4 if depth == 32 else 3
		FORMAT_555:
			return 2
	return 0


static func _expand4(c: int) -> int:
	return (c << 4) | c


static func _expand5(c: int) -> int:
	return (c << 3) | (c >> 2)


static func _expand6(c: int) -> int:
	return (c << 2) | (c >> 4)


static func _convert_pixel_to_rgba8(src: PackedByteArray, offset: int, fmt: int, depth: int, swap_rb: bool) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(4)

	match fmt & 0x0f00:
		FORMAT_DEFAULT:
			match depth:
				32: # assume 8888
					if swap_rb:
						out[0] = src[offset + 2]
						out[1] = src[offset + 1]
						out[2] = src[offset]
						out[3] = src[offset + 3]
					else:
						out[0] = src[offset]
						out[1] = src[offset + 1]
						out[2] = src[offset + 2]
						out[3] = src[offset + 3]
				24: # assume 888
					if swap_rb:
						out[0] = src[offset + 2]
						out[1] = src[offset + 1]
						out[2] = src[offset]
					else:
						out[0] = src[offset]
						out[1] = src[offset + 1]
						out[2] = src[offset + 2]
					out[3] = 255
				16: # assume 1555
					var p := (src[offset + 1] << 8) | src[offset]
					out[0] = _expand5((p >> 10) & 0x1F)
					out[1] = _expand5((p >> 5) & 0x1F)
					out[2] = _expand5(p & 0x1F)
					out[3] = 255 if (p >> 15) & 1 else 0
				8, 4: # assume LUM8
					out[0] = src[offset]
					out[1] = src[offset]
					out[2] = src[offset]
					out[3] = 255
				_:
					push_error("Unsupported depth for FORMAT_DEFAULT: %d" % depth)
					return PackedByteArray()
		FORMAT_8888:
			if depth == 32:
				if swap_rb:
					out[0] = src[offset + 2]
					out[1] = src[offset + 1]
					out[2] = src[offset]
					out[3] = src[offset + 3]
				else:
					out[0] = src[offset]
					out[1] = src[offset + 1]
					out[2] = src[offset + 2]
					out[3] = src[offset + 3]
		FORMAT_888:
			if swap_rb:
				out[0] = src[offset + 2]
				out[1] = src[offset + 1]
				out[2] = src[offset]
			else:
				out[0] = src[offset]
				out[1] = src[offset + 1]
				out[2] = src[offset + 2]
			out[3] = 255
		FORMAT_1555:
			var pixel := (src[offset + 1] << 8) | src[offset]
			out[0] = _expand5((pixel >> 10) & 0x1F)
			out[1] = _expand5((pixel >> 5) & 0x1F)
			out[2] = _expand5(pixel & 0x1F)
			out[3] = 255 if (pixel >> 15) & 1 else 0
		FORMAT_565:
			var pixel := (src[offset + 1] << 8) | src[offset]
			out[0] = _expand5((pixel >> 11) & 0x1F)
			out[1] = _expand6((pixel >> 5) & 0x3F)
			out[2] = _expand5(pixel & 0x1F)
			out[3] = 255
		FORMAT_4444:
			var pixel := (src[offset + 1] << 8) | src[offset]
			out[0] = _expand4((pixel >> 8) & 0xF)
			out[1] = _expand4((pixel >> 4) & 0xF)
			out[2] = _expand4(pixel & 0xF)
			out[3] = _expand4((pixel >> 12) & 0xF)
		FORMAT_555:
			var pixel := (src[offset + 1] << 8) | src[offset]
			out[0] = _expand5((pixel >> 10) & 0x1F)
			out[1] = _expand5((pixel >> 5) & 0x1F)
			out[2] = _expand5(pixel & 0x1F)
			out[3] = 255
		FORMAT_LUM8:
			out[0] = src[offset]
			out[1] = src[offset]
			out[2] = src[offset]
			out[3] = 255
		_:
			push_error("Unsupported raster format: 0x%04x" % (fmt & 0x0f00))
			return PackedByteArray()

	return out


static func _read_raster_image(stream: StreamPeerBuffer, width: int, height: int, depth: int, num_levels: int, raster_fmt: int, platform_id: int, format_or_alpha: int, flags: int) -> Image:
	if width <= 0 or height <= 0 or num_levels <= 0:
		return null
	var pal8 := (raster_fmt & FORMAT_EXT_PAL8) != 0
	var pal4 := (raster_fmt & FORMAT_EXT_PAL4) != 0
	var paletted := pal8 or pal4
	if pal8 and pal4:
		return null
	var compression := flags if platform_id == D3D8 else 0
	var swap_rb := true
	var auto_mipmap := (raster_fmt & FORMAT_EXT_AUTO_MIPMAP) != 0
	if platform_id == D3D9:
		if flags & 2:
			push_error("Cube rasters are not supported")
			return null
		auto_mipmap = auto_mipmap or (flags & 4) != 0
		if not paletted:
			# D3DFORMAT is authoritative on D3D9, including non-RW formats.
			match format_or_alpha:
				0x31545844: compression = 1 # DXT1
				0x33545844: compression = 3 # DXT3
				0x35545844: compression = 5 # DXT5
				20:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_888
					depth = 24
				21, 32:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_8888
					depth = 32
				22, 33:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_888
					depth = 32
				23:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_565
					depth = 16
				24:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_555
					depth = 16
				25:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_1555
					depth = 16
				26:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_4444
					depth = 16
				50:
					raster_fmt = (raster_fmt & ~0x0f00) | FORMAT_LUM8
					depth = 8
				_:
					push_error("Unsupported D3DFORMAT: 0x%08x" % format_or_alpha)
					return null
			swap_rb = format_or_alpha != 32 and format_or_alpha != 33
	if compression not in [0, 1, 3, 5] or (paletted and compression != 0):
		push_error("Unsupported raster compression: %d" % compression)
		return null
	var palette := PackedByteArray()
	if paletted:
		# PC palettes always contain RGBA8 entries; PAL4 stores 32 entries
		# and uses one byte per index, unlike PS2's packed nibbles.
		var palette_bytes := (256 if pal8 else 32) * 4
		if stream.get_available_bytes() < palette_bytes:
			return null
		var result := stream.get_data(palette_bytes)
		if result[0] != OK:
			return null
		palette = result[1]
		if (raster_fmt & 0x0f00) == FORMAT_888:
			for entry in palette.size() / 4:
				palette[entry * 4 + 3] = 255

	var max_levels := 1
	var max_dimension := maxi(width, height)
	while max_dimension > 1:
		max_dimension >>= 1
		max_levels += 1
	var data_levels := 1 if auto_mipmap else num_levels
	if data_levels > max_levels:
		return null
	var pixel_size := _get_sizeof_color(raster_fmt, depth)
	if not paletted and compression == 0 and (pixel_size == 0 or pixel_size * 8 != depth):
		return null

	var all_mips := PackedByteArray()
	var last_mip: Image

	for level in data_levels:
		if stream.get_available_bytes() < 4:
			return null
		var data_size := stream.get_u32()
		if data_size == 0 or data_size > stream.get_available_bytes():
			return null
		var result := stream.get_data(data_size)
		if result[0] != OK:
			return null
		var raw: PackedByteArray = result[1]
		var mip_w := maxi(1, width >> level)
		var mip_h := maxi(1, height >> level)
		var rgba8 := PackedByteArray()
		if compression != 0:
			var block_size := 8 if compression == 1 else 16
			var blocks_w := (mip_w + 3) / 4
			var blocks_h := (mip_h + 3) / 4
			if data_size != blocks_w * blocks_h * block_size:
				return null
			var image_format := Image.FORMAT_DXT1
			if compression == 3:
				image_format = Image.FORMAT_DXT3
			elif compression == 5:
				image_format = Image.FORMAT_DXT5
			# Decode full blocks, then crop sub-4x4 and NPOT mip levels.
			last_mip = Image.create_from_data(blocks_w * 4, blocks_h * 4, false, image_format, raw)
			if last_mip == null or last_mip.decompress() != OK:
				return null
			last_mip.convert(Image.FORMAT_RGBA8)
			last_mip = last_mip.get_region(Rect2i(0, 0, mip_w, mip_h))
			rgba8 = last_mip.get_data()
		else:
			var row_bytes := mip_w * (1 if paletted else pixel_size)
			var row_stride := (row_bytes + 3) & ~3
			# Some PC exporters omit scanline padding.
			if data_size == row_bytes * mip_h:
				row_stride = row_bytes
			elif data_size != row_stride * mip_h:
				return null
			for row in mip_h:
				var row_start := row * row_stride
				for x in mip_w:
					if paletted:
						var idx := raw[row_start + x]
						if idx >= (16 if pal4 else 256):
							return null
						rgba8.append_array(palette.slice(idx * 4, idx * 4 + 4))
					else:
						var off := row_start + x * pixel_size
						rgba8.append_array(_convert_pixel_to_rgba8(raw, off, raster_fmt, depth, swap_rb))
			last_mip = Image.create_from_data(mip_w, mip_h, false, Image.FORMAT_RGBA8, rgba8)

		all_mips.append_array(rgba8)

	# Godot requires a complete chain. Preserve authored levels and generate
	# only the missing tail from the last supplied level.
	if data_levels > 1 and data_levels < max_levels:
		if last_mip.generate_mipmaps() != OK:
			return null
		all_mips.append_array(last_mip.get_data().slice(last_mip.get_mipmap_offset(1)))
	var image := Image.create_from_data(width, height, data_levels > 1, Image.FORMAT_RGBA8, all_mips)

	if image != null and auto_mipmap:
		if image.generate_mipmaps() != OK:
			return null

	return image
