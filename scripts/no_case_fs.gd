class_name NoCaseFS
extends RefCounted

## A map of normalized (lowercase) file paths to their original paths
static var _map: Dictionary[String, String] = { }


static func index(path: String) -> bool:
	if !_check_abs_path(path):
		return false

	print("Indexing '%s' for case-insensitive access" % path)
	var result := _walk_dir(path)
	_map.merge(result, true)
	print("Indexed %d files" % result.size())
	return true


static func exists(path: String) -> bool:
	if !_check_abs_path(path):
		return false
	return _map.has(path.to_lower())


static func open(path: String, mode: FileAccess.ModeFlags) -> FileAccess:
	if !_check_abs_path(path):
		return null
	var key := path.to_lower()
	if !_map.has(key):
		return null
	return FileAccess.open(_map[key], mode)


static func _walk_dir(path: String) -> Dictionary[String, String]:
	var dir := DirAccess.open(path)
	if dir == null:
		return { }

	var result: Dictionary[String, String] = { }
	for fname in dir.get_files():
		var abs_path := path.path_join(fname)
		result[abs_path.to_lower()] = abs_path
	for dname in dir.get_directories():
		result.merge(_walk_dir(path.path_join(dname)))

	return result


static func _check_abs_path(path: String) -> bool:
	if !path.is_absolute_path():
		push_error("Path '%s' is not absolute" % path)
		return false
	return true
