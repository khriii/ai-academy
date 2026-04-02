class_name Collectible
extends Item

@export var collection_area: Area2D

var filename = get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"collection_area": collection_area,
	})


func collect():
	Global.collected_collectibles += 1
	Global.collectibles_updated.emit(Global.collected_collectibles)
	queue_free()
