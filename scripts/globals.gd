extends Node

signal collectibles_updated(new_total: int)

var lang_json_path: String = "res://components/lang/lang_it.json"
var collected_collectibles: int = 0


func print_error(filename, error_message):
	print(filename + ": " + error_message)

func print_missing(filename, error_message):
	print(filename + ": " + error_message + " missing")
