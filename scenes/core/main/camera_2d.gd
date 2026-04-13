class_name PlayerCamera
extends Camera2D

@export var left_limit: int = -50
@export var right_limit: int = 370
@export var top_limit: int = -50
@export var bottom_limit: int = 200

func _ready() -> void:
	limit_left = left_limit
	limit_right = right_limit
	limit_bottom = bottom_limit
	limit_top = top_limit
