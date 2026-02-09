extends Node2D

# ------------------ Variables --------------------
@export var markers : Array[Marker2D]
@export var npc : Npc

var current_index = 0

# ------------------ Methods ----------------------
func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if npc.finished_movement:
		npc.set_target_marker(markers[current_index])
		current_index += 1
		if current_index >= markers.size():
			current_index = 0
