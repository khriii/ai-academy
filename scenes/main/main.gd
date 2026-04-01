extends Node2D

@export var player: Player
@export var pause_menu: PauseMenu


func _ready() -> void:
	var new_item = Item.new()
	new_item.item_name = "test_item"
	
	player.inventory.addItem(new_item)
	
	print("Item: " + player.inventory.getItem(0).item_name)
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu._hide()
				get_tree().paused = false
			else:
				pause_menu._show()
				get_tree().paused = true
