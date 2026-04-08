extends Control

signal dialogue_finished

# Variables
@export var left_character: Sprite2D
@export var right_character: Sprite2D
@export var left_character_size: Vector2 = Vector2(3, 3)
@export var right_character_size: Vector2 = Vector2(3, 3)
@export var left_character_marker: Marker2D
@export var right_character_marker: Marker2D
@export var dialogue_label: Label
@export var dialogue_name: String
@export var lang_component: LangComponent

var current_dialogue: Array
var current_line: int = 0
var waiting_for_input: bool = false

var filename = get_script().get_path()

# Methods
func _ready() -> void:
	Global.check_nodes(filename, {
		"left_character": left_character,
		"right_character": right_character,
		"left_character_marker": left_character_marker,
		"right_character_marker": right_character_marker,
		"dialogue_label": dialogue_label
	})
	
	set_sprite_sizes()

func start_dialogue(d_name: String) -> void:
	dialogue_name = d_name
	play()

func set_sprite_sizes():
	left_character.scale = left_character_size
	right_character.scale = right_character_size

func _process(_delta: float) -> void:
	if waiting_for_input and Input.is_action_just_pressed("continue_dialogue"):
		show_next_line()

func play() -> void:
	current_dialogue = lang_component.get_dialogue(dialogue_name)
	current_line = 0
	show_next_line()

func show_next_line() -> void:
	if current_line >= current_dialogue.size():
		dialogue_finished.emit()
		queue_free()
		return
	
	var line = current_dialogue[current_line]
	current_line += 1
	
	# Show the text
	print(line.speaker + ": " + line.text)
	dialogue_label.text = line.text
	
	# Position characters (simple version)
	_update_character_position(line.position)
	
	# Wait for input
	waiting_for_input = true

func _update_character_position(speaker_position: String) -> void:
	if speaker_position.to_lower() == "left":
		left_character.global_position = left_character_marker.global_position
		left_character.show()
		right_character.hide()
	elif speaker_position.to_lower() == "right":
		right_character.global_position = right_character_marker.global_position
		right_character.show()
		left_character.hide()
	else:
		left_character.global_position = left_character_marker.global_position
		right_character.global_position = right_character_marker.global_position
		left_character.show()
		right_character.show()
