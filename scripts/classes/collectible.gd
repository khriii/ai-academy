class_name Collectible
extends Item

@export var collection_area: Area2D


func collect():
	queue_free()
