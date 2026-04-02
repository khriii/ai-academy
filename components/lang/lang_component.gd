class_name LangComponent
extends Node2D

var json_file_path: String = Global.lang_json_path
var data = null

var filename = get_script().get_path()


func _ready() -> void:
	load_json_data()


func load_json_data() -> void:
	if not FileAccess.file_exists(json_file_path):
		Global.print_error(filename, "JSON file not found in: " + json_file_path)
		return
	
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	data = JSON.parse_string(content)
	
	if data == null:
		Global.print_error(filename, "JSON parsing failed. Check file syntax")


func get_lang_text(key: String):
	if data == null:
		load_json_data()
		
	if data != null and data.has(key):
		return data[key]
	else:
		Global.print_error(filename, "Missing text key: " + key)
		return "ERROR_TEXT"


func get_dialogue(dialogue_name: String):
	if data == null:
		load_json_data()
		
	if data != null and data.has("dialogues") and data.dialogues.has(dialogue_name):
		return data.dialogues[dialogue_name]
	else:
		Global.print_error(filename, "Missing dialogue: " + dialogue_name)
		return []
