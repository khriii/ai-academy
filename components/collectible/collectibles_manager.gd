extends Node

signal counter_updated(new_value: int)

# Variables
var collected_counter: int
var collectibles_collected: Array = []

# Methods
func collect(collectible_id: String) -> void:
	if not is_already_collected(collectible_id):
		collectibles_collected.append(collectible_id)
		collected_counter += 1
		counter_updated.emit(collected_counter)

func is_already_collected(collectible_id: String) -> bool:
	return collectibles_collected.has(collectible_id)

func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	save_data["counter"] = collected_counter
	save_data["collected_ids"] = collectibles_collected
	return save_data

func load_save_data(data: Dictionary) -> void:
	collected_counter = data.get("counter", 0)
	collectibles_collected = data.get("collected_ids", [])
