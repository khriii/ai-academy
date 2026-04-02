class_name Npc
extends Entity

signal interaction_triggered(id: String)

# Variables
@export var movement_component: MovementComponent
@export var animation_component: AnimationComponent
@export var is_interactable: bool = true

var is_idle: bool = true

# Methods
func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"movement_component": movement_component,
		"animation_component": animation_component,
	})

func interact() -> void:
	if is_interactable:
		interaction_triggered.emit(id)

func walk(where: Vector2) -> void:
	if movement_component:
		var distance = global_position.distance_to(where)
		
		if distance <= 2:
			global_position = where
			is_idle = true
			movement_component.set_facing_direction(Vector2.ZERO)
		else:
			is_idle = false
			var direction = global_position.direction_to(where)
			movement_component.set_facing_direction(direction)
