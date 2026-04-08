class_name SceneChanger
extends Node2D

@export var next_scene: PackedScene

var filename = get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"next_scene": next_scene,
	})


func change_scene():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		Global.print_error(filename, "Cannot changes scene because 'next_scene' is null")
