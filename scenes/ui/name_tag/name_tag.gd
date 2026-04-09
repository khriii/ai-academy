extends Node2D

# Variables
@export var tag: String
@export var y_pos: float
@export var tag_label: Label

func _ready() -> void:
	if y_pos:
		var new_position = Vector2(position.x, position.y + y_pos)
		
		self.position = new_position
		
		if tag_label and tag:
			tag_label.text = tag

func _show():
	self.visible = true

func _hide():
	self.visible = false

func kill():
	queue_free()
