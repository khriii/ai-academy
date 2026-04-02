extends CanvasLayer

@export var collectibles_counter: CollectiblesCounter

func increment_collectibles(step: int):
	collectibles_counter.increment(step)

func decrement_collectibles(step: int):
	collectibles_counter.decrement(step)
