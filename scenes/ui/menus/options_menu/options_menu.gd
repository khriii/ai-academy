class_name OptionsMenu
extends CanvasLayer

@export var settings_title: Label
@export var screen_title: Label
@export var language_title: Label

@export var resolution_options: OptionButton
@export var fullscreen_checkbox: CheckBox
@export var language_options: OptionButton
@export var back_button: Button

var filename: String = "options_menu.gd"

func change_language():
	if settings_title:
		settings_title.text = LangComponent.get_options_menu_text("settings_title")
	if screen_title:
		screen_title.text = LangComponent.get_options_menu_text("screen_title")
	if fullscreen_checkbox:
		fullscreen_checkbox.text = LangComponent.get_options_menu_text("fullscreen_text")
	if language_title:
		language_title.text = LangComponent.get_options_menu_text("language_title")
	if back_button:
		back_button.text = LangComponent.get_options_menu_text("back_button")

func _ready() -> void:
	Global.check_nodes(filename, {
		"resolution_options": resolution_options,
		"fullscreen_checkbox": fullscreen_checkbox,
		"language_options": language_options,
		"back_button": back_button
	})
	
	if language_options:
		match Global.current_language:
			"it":
				language_options.select(0)
			"en":
				language_options.select(1)
	
	change_language()
	EventBus.language_changed.connect(change_language)
	
	
	if resolution_options:
		resolution_options.item_selected.connect(_on_resolution_selected)
	if fullscreen_checkbox:
		fullscreen_checkbox.toggled.connect(_on_fullscreen_checkbox_toggled)
	if language_options:
		language_options.item_selected.connect(_on_language_selected)
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)


func _show():
	self.visible = true


func _hide():
	self.visible = false


# Signals
func _on_resolution_selected(index: int):
	pass


func _on_fullscreen_checkbox_toggled(button_pressed: bool):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_language_selected(index: int):
	if language_options:
		var language: String = language_options.get_item_text(index)
		var new_language_short = Global.current_language
		
		match language:
			"English":
				new_language_short = "en"
			"Italian":
				new_language_short = "it"
			_:
				# TODO: handle error
				pass
		LangComponent.change_language(new_language_short)


func _on_back_button_pressed():
	self._hide()
