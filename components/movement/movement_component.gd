class_name MovementComponent
extends Node

# ------------------ Variables --------------------
@export var entity : CharacterBody2D
@export var speed : float = 300.0

var facing_direction : Vector2 = Vector2.DOWN
var input_direction : Vector2 = Vector2.ZERO

var filename = get_script().get_path()

# ------------------ Methods ----------------------
func _ready() -> void:
	Global.check_nodes(filename, {
		"entity": entity,
	})
	
	if entity is Player:
		facing_direction = entity.start_facing_direction

func set_facing_direction(direction: Vector2) -> void:
	if direction.length() > 0:
		facing_direction = direction.normalized()
	input_direction = direction.normalized()

func _physics_process(_delta: float) -> void:
	if entity:
		if input_direction == Vector2.ZERO:
			entity.velocity = Vector2.ZERO
		else:
			entity.velocity = input_direction * speed
			entity.move_and_slide()
