class_name CustomerAI
extends Node

# ------------------ Variables --------------------
@export var seats_node : Node2D

var seats : Array[Seat]
var prefix : String = "[CustomerAI]"

# ------------------ Methods ----------------------
# method to append all seats
func append_seats() -> void:
	var seats_node_children = seats_node.get_children()
	
	for seat in seats_node_children:
		seats.append(seat)


# cycle to all seats and return the first found one as Seat
func find_free_seat() -> Seat:
	for seat in seats:
		if seat.is_free:
			return seat
	return null


func _ready() -> void:
	print(prefix + " loaded")
	
	# append to the array all the seats in the seats_node
	append_seats()
	
	var seat: Seat = find_free_seat()
	
	if seat:
		seat.is_free = false
		$"../Npc".set_target_marker(seat.marker)


func _process(_delta: float) -> void:
	pass
