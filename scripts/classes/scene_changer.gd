class_name SceneChanger
extends Node2D

@export var next_scene: PackedScene

func change_scene():
	get_tree().change_scene_to_packed(next_scene)
