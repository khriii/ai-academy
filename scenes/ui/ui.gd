extends CanvasLayer

@export var collectibles_counter: CollectiblesCounter

var filename = get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"collectibles_counter": collectibles_counter,
	})


func increment_collectibles(step: int):
	collectibles_counter.increment(step)


func decrement_collectibles(step: int):
	collectibles_counter.decrement(step)
