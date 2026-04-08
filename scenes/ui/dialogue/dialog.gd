class_name Dialog
extends CanvasLayer

signal dialogue_finished

@export var left_talker: TextureRect
@export var right_talker: TextureRect
@export var dialog_label: Label 

var current_dialog: Array = []
var current_dialog_index: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue_dialogue"):
		get_viewport().set_input_as_handled()
		play_next_dialog()

func load_dialog(dialog_id: String, stage: int):
	current_dialog.clear()
	current_dialog_index = 0
	
	var file_path = LangComponent.get_dialogue_path(dialog_id, stage)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		return
	
	current_dialog = json.data

func load_texture_from_path(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	else:
		return null

func render_dialog_label_text(text: String):
	dialog_label.text = text

func render_left_talker():
	if left_talker:
		left_talker.visible = true
	if right_talker:
		right_talker.visible = false

func render_right_talker():
	if left_talker:
		left_talker.visible = false
	if right_talker:
		right_talker.visible = true

func play_next_dialog():
	if not current_dialog:
		_end_dialogue()
		return
	
	if current_dialog_index >= current_dialog.size():
		_end_dialogue()
		return
	
	var d = current_dialog[current_dialog_index]
	render_dialog_label_text(d.dialog)
	
	if d.has("talker_texture"):
		var texture = load_texture_from_path(d.talker_texture)
		if d.talker_position == "left" and left_talker:
			left_talker.texture = texture
		elif d.talker_position == "right" and right_talker:
			right_talker.texture = texture
	
	if d.talker_position == "left":
		render_left_talker()
	elif d.talker_position == "right":
		render_right_talker()
	
	current_dialog_index += 1


func skip_dialogue() -> void:
	_end_dialogue()


func _end_dialogue() -> void:
	Global.is_dialogue_active = false
	dialogue_finished.emit()
	queue_free()


func _ready() -> void:
	Global.is_dialogue_active = true
