class_name Npc
extends Entity

# ------------------ Variables --------------------
@export var target_marker : Marker2D

var finished_movement : bool = true

var filename = get_script().get_path()

# ------------------ Methods ----------------------
func _ready() -> void:
	Global.check_nodes(filename, {
		"target_marker": target_marker,
	})


func set_target_marker(marker: Marker2D) -> void:
	target_marker = marker


func _process(_delta: float) -> void:
	if not target_marker: return
	
	var distance = global_position.distance_to(target_marker.global_position)
	
	if distance <= 2:
		global_position = target_marker.global_position
		finished_movement = true
		movement_component.set_facing_direction(Vector2.ZERO)
	else:
		finished_movement = false
		var direction = global_position.direction_to(target_marker.global_position)
		movement_component.set_facing_direction(direction)
