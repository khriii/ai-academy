class_name Collectible
extends Item

signal item_collected(id: String)

# Variables
@export var collection_area: Area2D

var filename = get_script().get_path()

# Methods
func _ready() -> void:
	if CollectiblesManager.is_already_collected(id):
		queue_free()
		return

	Global.check_nodes(filename, {
		"collection_area": collection_area,
	})
	
	load_signals()

func load_signals():
	if collection_area:
		collection_area.body_entered.connect(_on_collect)

func _on_collect(body: Node):
	if body is Player:
		item_collected.emit(id)
		queue_free()
