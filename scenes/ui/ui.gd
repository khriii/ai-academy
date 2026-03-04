extends Control

@export var collectibles_counter: Label


func _process(_delta: float) -> void:
	collectibles_counter.text = str(Global.collected_collectibles)
