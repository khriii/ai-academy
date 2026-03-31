class_name LangComponent
extends Node2D

var json_file_path: String = Global.lang_json_path
var data = null
var filename: String = "LangComponent.gd"

func _ready() -> void:
	load_json_data()

func print_error(error_message: String) -> void:
	print(filename + ": " + error_message)

func load_json_data() -> void:
	if not FileAccess.file_exists(json_file_path):
		print_error("JSON file not found -> " + json_file_path)
		return
	
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	data = JSON.parse_string(content)
	
	if data == null:
		print_error("JSON parsing failed. Check file syntax.")

func get_lang_text(key: String):
	if data == null:
		load_json_data()
		
	if data != null and data.has(key):
		return data[key]
	else:
		print_error("Missing text key -> " + key)
		return "ERROR_TEXT"

func get_dialogue(dialogue_name: String):
	if data == null:
		load_json_data()
		
	if data != null and data.has("dialogues") and data.dialogues.has(dialogue_name):
		return data.dialogues[dialogue_name]
	else:
		print_error("Missing dialogue -> " + dialogue_name)
		return []
