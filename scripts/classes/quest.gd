class_name Quest
extends Node

signal quest_completed(quest_id: String)

var quest_id: String
var _name: String
var description: String
var completed: bool = false

func _init(p_quest_id: String, p_name: String, p_description: String, p_completed: bool = false) -> void:
	quest_id = p_quest_id
	_name = p_name
	description = p_description
	completed = p_completed

func complete():
	if completed:
		return
	completed = true
	quest_completed.emit(quest_id)
