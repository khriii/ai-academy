class_name PauseMenu
extends CanvasLayer

@export var continue_button: Button
@export var options_button: Button
@export var options_menu: OptionsMenu

var filename = self.get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"continue_button": continue_button,
		"options_button": options_button,
		"options_menu": options_menu,
	})
	
	if continue_button:
		continue_button.pressed.connect(on_continue_button_pressed)
	if options_button:
		options_button.pressed.connect(on_options_button_pressed)
	if options_menu:
		options_menu._hide()


func _show():
	self.visible = true


func _hide():
	self.visible = false
	get_tree().paused = false


func on_continue_button_pressed():
	self._hide()


func on_options_button_pressed():
	if options_menu: options_menu._show()
