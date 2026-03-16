extends Control

@export var lang_component: LangComponent

@export var start_message_label: Label
@export var quit_button: Button

func _ready() -> void:
	start_message_label.text = lang_component.get_lang_text("start_message_label")
	quit_button.text = lang_component.get_lang_text("quit_button")
	
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_quit_button_pressed():
	get_tree().quit()
