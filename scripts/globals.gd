extends Node

signal collectibles_updated(new_total: int)

var current_language = "test"

var is_dialogue_active: bool = false


func print_error(filename, error_message):
	print(filename + ": " + error_message)


func print_missing(filename, error_message):
	print(filename + ": " + error_message + " missing")


func check_nodes(filename: String, nodes_dict: Dictionary):
	for node_name in nodes_dict:
		if not nodes_dict[node_name]:
			print_missing(filename, node_name)
