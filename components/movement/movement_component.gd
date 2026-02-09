class_name MovementComponent
extends Node

# ------------------ Variables --------------------
@export var entity : CharacterBody2D
@export var speed : float = 300.0

var facing_direction : Vector2 = Vector2.DOWN
var input_direction : Vector2 = Vector2.ZERO
var prefix : String = "[MovementComponent]"

# ------------------ Methods ----------------------
func _ready() -> void:
	print(prefix + " loaded")

func set_facing_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		facing_direction = direction.normalized()
	input_direction = direction.normalized()
	


func _process(_delta: float) -> void:
	if (entity):
		entity.velocity = input_direction * speed
		
		entity.move_and_slide()
