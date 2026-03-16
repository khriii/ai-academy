extends Control

@export var left_character: Sprite2D
@export var right_character: Sprite2D
@export var left_character_marker: Marker2D
@export var right_character_marker: Marker2D
@export var dialogue_label: Label
@export var dialogue_name: String

@export var lang_component: LangComponent

var file_name: String = "dialogue_manager.gd"

func _ready() -> void:
	if not left_character:
		print(file_name + ": left_character missing")
	if not right_character:
		print(file_name + ": right_character missing")
	if not left_character_marker:
		print(file_name + ": left_character_marker missing")
	if not right_character_marker:
		print(file_name + ": right_character_marker missing")
	if not dialogue_label:
		print(file_name + ": dialogue_label missing")
		
	play()
	
func play():
	var dialogue = lang_component.get_dialogue(dialogue_name)
	
	for d in dialogue:
		var speaker = d.speaker
		var text = d.text
		
		print(speaker, ": ", text)
