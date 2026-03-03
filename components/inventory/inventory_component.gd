class_name InventoryComponent
extends Node

@export var inventory_slots: int = 3

var inventory: Array[Item] = []

func addItem(item: Item) -> bool:
	# Check if inventory is full
	if inventory.size() >= inventory_slots:
		print("Inventory is full!")
		return false
	
	# Add item to inventory
	inventory.append(item)
	print("Added ", item.name, " to inventory. Slots used: ", inventory.size(), "/", inventory_slots)
	return true

func removeItem(item: Item) -> bool:
	# Check if item exists in inventory
	if item in inventory:
		inventory.erase(item)
		print("Removed ", item.name, " from inventory. Slots used: ", inventory.size(), "/", inventory_slots)
		return true
	else:
		print("Item not found in inventory!")
		return false

func removeItemByIndex(index: int) -> bool:
	# Check if index is valid
	if index >= 0 and index < inventory.size():
		var removed_item = inventory[index]
		inventory.remove_at(index)
		print("Removed ", removed_item.name, " from inventory at index ", index)
		return true
	else:
		print("Invalid inventory index!")
		return false

func hasItem(item: Item) -> bool:
	return item in inventory

func getItem(index: int) -> Item:
	if index >= 0 and index < inventory.size():
		return inventory[index]
	return null

func isFull() -> bool:
	return inventory.size() >= inventory_slots

func isEmpty() -> bool:
	return inventory.size() == 0

func clear() -> void:
	inventory.clear()
	print("Inventory cleared")
