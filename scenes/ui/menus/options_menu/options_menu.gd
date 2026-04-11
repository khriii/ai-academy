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

const SUPPORTED_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

var available_resolutions: Array[Vector2i] = []

var config: ConfigFile = ConfigFile.new()
const CONFIG_PATH: String = "user://settings.cfg"

func change_language() -> void:
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
	
	_populate_resolutions()
	_load_settings()
	
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
	
	call_deferred("_apply_loaded_settings")

func _populate_resolutions() -> void:
	if not resolution_options:
		return
		
	resolution_options.clear()
	available_resolutions.clear()
	
	var screen_index: int = DisplayServer.window_get_current_screen()
	var screen_size: Vector2i = DisplayServer.screen_get_size(screen_index)
	
	for res: Vector2i in SUPPORTED_RESOLUTIONS:
		if res.x <= screen_size.x and res.y <= screen_size.y:
			available_resolutions.append(res)
			resolution_options.add_item("%dx%d" % [res.x, res.y])

func _load_settings() -> void:
	config.load(CONFIG_PATH)

func _apply_loaded_settings() -> void:
	if config.has_section_key("video", "resolution"):
		var saved_res: Vector2i = config.get_value("video", "resolution")
		var idx: int = available_resolutions.find(saved_res)
		
		if idx != -1:
			resolution_options.select(idx)
			DisplayServer.window_set_size(saved_res)
			_center_window()
		else:
			if available_resolutions.size() > 0:
				var max_idx: int = available_resolutions.size() - 1
				var fallback_res: Vector2i = available_resolutions[max_idx]
				resolution_options.select(max_idx)
				DisplayServer.window_set_size(fallback_res)
				_center_window()
	
	if config.has_section_key("video", "fullscreen"):
		var fs: bool = config.get_value("video", "fullscreen")
		fullscreen_checkbox.set_pressed_no_signal(fs) 
		
		if resolution_options:
			resolution_options.disabled = fs
		
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _save_resolution(res: Vector2i) -> void:
	config.set_value("video", "resolution", res)
	config.save(CONFIG_PATH)

func _save_fullscreen(enabled: bool) -> void:
	config.set_value("video", "fullscreen", enabled)
	config.save(CONFIG_PATH)

func _save_language(lang: String) -> void:
	config.set_value("language", "current", lang)
	config.save(CONFIG_PATH)

func _center_window() -> void:
	var screen_index: int = DisplayServer.window_get_current_screen()
	var screen_size: Vector2i = DisplayServer.screen_get_size(screen_index)
	var window_size: Vector2i = DisplayServer.window_get_size()
	var screen_pos: Vector2i = DisplayServer.screen_get_position(screen_index)
	
	var new_pos: Vector2i = screen_pos + (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_pos)

func _on_resolution_selected(index: int) -> void:
	if index < 0 or index >= available_resolutions.size():
		return
		
	var selected_res: Vector2i = available_resolutions[index]
	
	DisplayServer.window_set_size(selected_res)
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		_center_window()
	
	_save_resolution(selected_res)

func _on_fullscreen_checkbox_toggled(button_pressed: bool) -> void:
	if resolution_options:
		resolution_options.disabled = button_pressed

	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var idx: int = resolution_options.selected
		if idx >= 0:
			_on_resolution_selected(idx)
	
	_save_fullscreen(button_pressed)

func _on_language_selected(index: int) -> void:
	if language_options:
		var language: String = language_options.get_item_text(index)
		var new_language_short: String = Global.current_language
		
		match language:
			"English":
				new_language_short = "en"
			"Italian":
				new_language_short = "it"
		LangComponent.change_language(new_language_short)
		_save_language(new_language_short)

func _on_back_button_pressed() -> void:
	_hide()

func _show() -> void:
	self.visible = true

func _hide() -> void:
	self.visible = false
