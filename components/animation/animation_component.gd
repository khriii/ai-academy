class_name AnimationComponent
extends Node

# ------------------ Variables --------------------
@export var entity : Entity
@export var sprite : AnimatedSprite2D
@export var movement_component : MovementComponent

var prefix : String = "[AnimationComponent]"

# ------------------ Methods ----------------------
func _ready() -> void:
	print(prefix + " loaded")


func apply_animation(animation_prefix: String, facing_direction: Vector2) -> void:
	var animation_direction: String = "down"
	
	if facing_direction.x > 0:
		animation_direction = "right"
		#sprite.flip_h = false
	elif facing_direction.x < 0:
		animation_direction = "left"
		#sprite.flip_h = true
	if facing_direction.y > 0 or (facing_direction.x > 0 and facing_direction.y > 0):
		animation_direction = "down"
	if facing_direction.y < 0 or (facing_direction.x < 0 and facing_direction.y < 0):
		animation_direction = "up"
	
	sprite.play(animation_prefix + "_" + animation_direction)


func _process(_delta: float) -> void:
	if entity and sprite and movement_component:
		var facing_direction : Vector2 = movement_component.facing_direction
		
		if entity.velocity.length() > 0:
			apply_animation("walk", facing_direction)
		else:
			apply_animation("idle", facing_direction)
