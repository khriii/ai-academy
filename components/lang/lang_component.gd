class_name LangComponent
extends Node2D

var json_file_path: String = Global.lang_json_path

var data

func _ready() -> void:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	data = JSON.parse_string(content)


func get_lang_text(key: String):
	return data[key]
