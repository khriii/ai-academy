class_name Item
extends Node2D

@export var item_name: String

func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"item_name": item_name,
	})
