class_name PauseMenu
extends CanvasLayer

@export var continue_button: Button
@export var options_button: Button
@export var options_menu: OptionsMenu

var filename = "pause_menu.gd"

func _ready() -> void:
	check_nodes()
	
	if continue_button:
		continue_button.pressed.connect(on_continue_button_pressed)
	if options_button:
		options_button.pressed.connect(on_options_button_pressed)
	if options_menu:
		options_menu._hide()

func print_error(error_message):
	print(filename + ": " + error_message)

func check_nodes():
	if not continue_button: print_error("continue_button missing")
	if not options_button: print_error("options_button missing")
	if not options_menu: print_error("options_menu missing")

func _show():
	self.visible = true

func _hide():
	self.visible = false
	get_tree().paused = false

func on_continue_button_pressed():
	self._hide()

func on_options_button_pressed():
	if options_menu: options_menu._show()
