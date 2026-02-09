class_name Entity
extends CharacterBody2D

# ------------------ Variables --------------------
@export var movement_component : MovementComponent
@export var animation_component : AnimationComponent

# ------------------ Methods ----------------------
func _ready() -> void:
	var prefix : String = "[Entity]"
	print(prefix + " loaded")
