extends CanvasLayer

signal dialogue_finished

# Variables
@export var left_character: TextureRect
@export var right_character: TextureRect
@export var left_character_size: Vector2 = Vector2(1, 1)
@export var right_character_size: Vector2 = Vector2(1, 1)
@export var dialogue_label: Label
@export var dialogue_name: String
@export var lang_component: LangComponent

var portraits: Dictionary = {
	"doc_epoch": preload("res://assets/sprites/doc_epoch/doc_epoch1.png"),
	"neura": preload("res://assets/sprites/neura/idleForward/frame_01.png")
}

var current_dialogue: Array
var current_line: int = 0
var waiting_for_input: bool = false

var filename = get_script().get_path()

# Methods
func _ready() -> void:
	Global.check_nodes(filename, {
		"left_character": left_character,
		"right_character": right_character,
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
	
	# Passiamo TUTTA la riga alla funzione per aggiornare le grafiche
	_update_character_visuals(line)
	
	# Wait for input
	waiting_for_input = true


func _update_character_visuals(line: Dictionary) -> void:
	var speaker_position: String = line.get("position", "left").to_lower()
	var s_id: String = line.get("speaker_id", "")

	var new_texture = null
	if portraits.has(s_id):
		new_texture = portraits[s_id]
	else:
		if s_id != "":
			printerr("Nessun ritratto trovato per l'id: ", s_id)
			
	if speaker_position == "left":
		if new_texture: 
			left_character.texture = new_texture
		left_character.show()
		right_character.hide()
		
	elif speaker_position == "right":
		if new_texture: 
			right_character.texture = new_texture
		right_character.show()
		left_character.hide()
		
	else:
		left_character.show()
		right_character.show()
