class_name Player
extends Entity

@export var inventory: InventoryComponent
@export var movement_component: MovementComponent
@export var animation_component: AnimationComponent

func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"inventory": inventory,
		"movement_component": movement_component,
		"animation_component": animation_component,
	})


func _input(_event: InputEvent) -> void:
	var facing_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	movement_component.set_facing_direction(facing_direction)
