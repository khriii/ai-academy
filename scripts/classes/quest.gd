class_name Quest
extends Node

signal quest_completed(quest_id)

# Variables
var id: String
var _name: String
var description: String
var completed: bool = false

# Methods
func _init(p_id: String, p_name: String, p_description: String, p_completed: bool) -> void:
	id = p_id
	_name = p_name
	description = p_description
	completed = p_completed

func complete():
	if completed:
		return
	
	completed = true
	quest_completed.emit(id)
