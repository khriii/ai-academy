extends Control

@export var resume_button: Button
@export var settings_button: Button
@export var settings_menu: SettingsMenu

var filename = "pause_menu.gd"

func _ready() -> void:
	check_nodes()
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)

func print_error(error_message):
	print(filename + ": " + error_message)

func check_nodes():
	if not resume_button: print_error("resume_button missing")
	if not settings_button: print_error("settings_button missing")
	if not settings_menu: print_error("settings_menu missing")

func _on_resume_button_pressed():
	queue_free()

func _on_settings_button_pressed():
	print("open settings")
	
	if settings_menu:
		settings_menu.visible = true
