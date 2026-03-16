extends Node2D

@export var scene_changer: SceneChanger

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode:
			get_tree().change_scene_to_packed(scene_changer.next_scene)
