class_name Collectible
extends Item

@export var collection_area: Area2D

func _ready() -> void:
	collection_area.body_entered.connect(onCollect)

# run this method only when the body is a player
func onCollect(body: Node2D):
	if body is Player:
		queue_free()
