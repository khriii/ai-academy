extends Node2D

@export var player: Player

func _ready() -> void:
	var new_item = Item.new()
	new_item.item_name = "test_item"
	
	player.inventory.addItem(new_item)
	
	print("Item: " + player.inventory.getItem(0).item_name)
