class_name ModelFS
extends RefCounted

## Search paths
static var _search_paths: Array[String] = []
## Extracted CD images
static var _cd_images: Array[String] = []
## Temporary directory for extracted models
static var _temp_dir := DirAccess.create_temp("openliberty-cdimage")


## Add directory to search paths
static func add_directory(path: String) -> void:
	if NoCaseFS.index(path):
		_search_paths.append(path)
		print("Added '%s' to model search paths" % path)


## Add CD image
static func add_cd_image(path: String) -> void:
	var img := NoCaseFS.open(path, FileAccess.READ)
	if img == null:
		return
	var dir := NoCaseFS.open(path.get_basename() + ".dir", FileAccess.READ)
	if dir == null:
		return

	print("Adding CD image '%s'..." % path)
	var entries: Array[DirEntry] = []
	@warning_ignore("INTEGER_DIVISION")
	for i in dir.get_length() / 32:
		var entry := DirEntry.new()
		entry.offset = dir.get_32() * 2048
		entry.size = dir.get_32() * 2048
		var namebuf := dir.get_buffer(24)
		entry.name = namebuf.slice(0, namebuf.find(0)).get_string_from_ascii()
		entries.append(entry)

	for entry in entries:
		var out := FileAccess.open(_temp_dir.get_current_dir().path_join(entry.name.to_lower()), FileAccess.WRITE)
		if out == null:
			continue

		img.seek(entry.offset)
		out.store_buffer(img.get_buffer(entry.size))

	print("Extracted %d files from CD image '%s'" % [entries.size(), path])


static func exists(path: String) -> bool:
	for spath in _search_paths:
		if NoCaseFS.exists(spath.path_join(path)):
			return true

	if path.is_absolute_path():
		return NoCaseFS.exists(path)
	else:
		return _temp_dir.file_exists(path.to_lower())


static func open(path: String, mode: FileAccess.ModeFlags) -> FileAccess:
	for spath in _search_paths:
		if NoCaseFS.exists(spath.path_join(path)):
			return NoCaseFS.open(spath.path_join(path), mode)

	if path.is_absolute_path():
		return NoCaseFS.open(path, mode)
	else:
		return FileAccess.open(_temp_dir.get_current_dir().path_join(path.to_lower()), mode)


class DirEntry:
	var offset: int
	var size: int
	var name: String
