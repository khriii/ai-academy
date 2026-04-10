extends Node2D

var _data_cache: Dictionary = {}

const DATA_PATHS := {
	"main_menu": "menus/main_menu.json",
	"pause_menu": "menus/pause_menu.json",
	"options_menu": "menus/options_menu.json",
	"dialogs": "dialogs/{0}/stage_{1}.json",
	"quests": "quests/{0}.json",
	"items": "items/{0}.json"
}

var filename = get_script().get_path()


func load_data(data_type: String, params: Array = []) -> Dictionary:
	var cache_key = data_type + str(params)
	
	if _data_cache.has(cache_key):
		return _data_cache[cache_key]
	
	var relative_path = DATA_PATHS[data_type].format(params)
	var full_path = "res://assets/data/" + Global.current_language + "/" + relative_path
	
	if not FileAccess.file_exists(full_path):
		Global.print_error(filename, "JSON not found: " + full_path)
		return {}
	
	var file = FileAccess.open(full_path, FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	
	if data == null:
		Global.print_error(filename, "JSON parsing failed: " + full_path)
		return {}
	
	_data_cache[cache_key] = data
	return data


func get_dialogue_path(dialogue_id: String, stage: int) -> String:
	return "res://assets/data/" + Global.current_language + "/dialogs/" + dialogue_id + "/stage_" + str(stage) + ".json"


func get_dialogue(dialogue_id: String, stage: int) -> Array:
	var data = load_data("dialogs", [dialogue_id, stage])
	return data.get(dialogue_id + "_stage_" + str(stage), [])


func get_main_menu_text(key: String) -> String:
	var data = load_data("main_menu")
	return data.get(key, "ERROR_TEXT")


func get_pause_menu_text(key: String) -> String:
	var data = load_data("pause_menu")
	return data.get(key, "ERROR_TEXT")

func get_options_menu_text(key: String) -> String:
	var data = load_data("options_menu")
	return data.get(key, "ERROR_TEXT")


func change_language(new_language: String) -> void:
	Global.current_language = new_language
	clear_cache()
	EventBus.language_changed.emit()


func clear_cache() -> void:
	_data_cache.clear()


func reload_all() -> void:
	clear_cache()
	load_data("main_menu")
