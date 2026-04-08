class_name Seat
extends Node2D

# ------------------ Variables --------------------
@export var is_free: bool = true
@export var marker: Marker2D

var filename = get_script().get_path()

# ------------------ Methods ----------------------
func _ready() -> void:
	Global.check_nodes(filename, {
		"marker": marker,
	})
