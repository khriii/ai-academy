class_name PauseMenu
extends CanvasLayer

@export var continue_button: Button
@export var options_button: Button
@export var quit_button: Button

@export var options_menu: OptionsMenu

var filename = self.get_script().get_path()

func change_language():
	if continue_button:
		continue_button.text = LangComponent.get_pause_menu_text("continue_button")
	if options_button:
		options_button.text = LangComponent.get_pause_menu_text("options_button")
	if quit_button:
		quit_button.text = LangComponent.get_pause_menu_text("quit_button")


func _ready() -> void:
	Global.check_nodes(filename, {
		"continue_button": continue_button,
		"options_button": options_button,
		"options_menu": options_menu,
	})
	
	change_language()
	EventBus.language_changed.connect(change_language)
	
	if continue_button:
		continue_button.pressed.connect(on_continue_button_pressed)
	if options_button:
		options_button.pressed.connect(on_options_button_pressed)
	if quit_button:
		quit_button.text = LangComponent.get_pause_menu_text("quit_button")
		# TODO: handle button press
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
