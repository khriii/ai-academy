class_name Item
extends Node2D

# Variables
@export var id: String
@export var _name: String

# Methods
func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"id": id,
		"_name": _name,
	})
