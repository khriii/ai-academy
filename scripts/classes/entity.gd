class_name Entity
extends CharacterBody2D

# ------------------ Variables --------------------
@export var movement_component : MovementComponent
@export var animation_component : AnimationComponent

var filename = get_script().get_path()

# ------------------ Methods ----------------------
func _ready() -> void:
	Global.check_nodes(filename, {
		"movement_component": movement_component,
		"animation_component": animation_component,
	})
