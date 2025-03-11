@tool
extends EditorImportPlugin


func _get_importer_name():
	return "online.poeticandroid.text_resource_importer"


func _get_visible_name():
	return "Text Resource"


func _get_recognized_extensions():
	return ["txt"]


func _get_save_extension():
	return "tres"


func _get_resource_type():
	return "TextResource"


func _get_preset_count():
	return 1


func _get_preset_name(preset_index):
	return "Default"


func _get_import_options(path, preset_index):
	return []


func _get_priority():
	return 1.0


func _get_import_order() -> int:
	return 0


func _import(source_file, save_path, options, platform_variants, gen_files):
	var res = TextResource.new()
	res.text = FileAccess.get_file_as_string(source_file)

	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(res, filename)
