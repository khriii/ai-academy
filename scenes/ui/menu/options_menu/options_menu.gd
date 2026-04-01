class_name OptionsMenu
extends CanvasLayer

@export var fullscreen_check_button: CheckButton
@export var volume_slider: HSlider
@export var exit_button: Button

var filename: String = "options_menu.gd"

func _ready() -> void:
	check_nodes()
	
	if fullscreen_check_button:
		fullscreen_check_button.toggled.connect(_on_fullscreen_checkbox_toggled)
	if volume_slider:
		volume_slider.drag_ended.connect(_on_volume_slider_dragged)
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)

func print_error(error_message):
	print(filename + ": " + error_message)

func check_nodes():
	if not fullscreen_check_button: print_error("fullscreen_checkbox missing")
	if not volume_slider: print_error("volume_slider missing")
	if not exit_button: print_error("exit_button missing")

func _show():
	self.visible = true

func _hide():
	self.visible = false

func _on_fullscreen_checkbox_toggled(button_pressed: bool):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_dragged():
	pass

func _on_exit_button_pressed():
	self._hide()
