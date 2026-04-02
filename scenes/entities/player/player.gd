class_name Player
extends Entity

@export var inventory: InventoryComponent


func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"inventory": inventory,
	})


func _input(_event: InputEvent) -> void:
	var facing_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	movement_component.set_facing_direction(facing_direction)
