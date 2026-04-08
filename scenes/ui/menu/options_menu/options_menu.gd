class_name OptionsMenu
extends CanvasLayer

@export var fullscreen_check_button: CheckButton
@export var volume_slider: HSlider
@export var exit_button: Button

var filename: String = "options_menu.gd"


func _ready() -> void:
	Global.check_nodes(filename, {
		"fullscreen_check_button": fullscreen_check_button,
		"volume_slider": volume_slider,
		"exit_button": exit_button
	})
	
	if fullscreen_check_button:
		fullscreen_check_button.toggled.connect(_on_fullscreen_checkbox_toggled)
	if volume_slider:
		volume_slider.drag_ended.connect(_on_volume_slider_dragged)
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)

func print_error(error_message):
	print(filename + ": " + error_message)


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
