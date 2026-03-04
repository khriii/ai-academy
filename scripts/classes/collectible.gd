class_name Collectible
extends Item

@export var collection_area: Area2D


func collect():
	Global.collected_collectibles += 1
	queue_free()
