extends Node2D

@export var scene_changer: SceneChanger
@export var animation_player: AnimationPlayer

# Labels and Buttons
@export var start_message_label: Label
@export var new_game_button: Button
@export var continue_button: Button
@export var options_button: Button
@export var achievements_button: Button
@export var exit_button: Button

var filename = "menu_handler.gd"

func print_error(error_message):
	print(filename + ": " + error_message)

func check_nodes():
	if not start_message_label: print_error("start_message_label missing")
	if not animation_player: print_error("animation_player missing")
	if not new_game_button: print_error("new_game_button missing")
	if not continue_button: print_error("continue_button missing")
	if not options_button: print_error("options_button missing")
	if not achievements_button: print_error("achievements_button missing")
	if not exit_button: print_error("exit_button missing")

func _ready() -> void:
	check_nodes()
	load_language()
	load_click_handlers()

func load_language():
	if start_message_label:
		start_message_label.text = Lang.get_lang_text("start_message_label")
	if new_game_button:
		new_game_button.text = Lang.get_lang_text("new_game_button")
	if continue_button:
		continue_button.text = Lang.get_lang_text("continue_button")
	if options_button:
		options_button.text = Lang.get_lang_text("options_button")
	if achievements_button:
		achievements_button.text = Lang.get_lang_text("achievements_button")
	if exit_button:
		exit_button.text = Lang.get_lang_text("exit_button")

func load_click_handlers():
	if new_game_button:
		new_game_button.pressed.connect(on_new_game_pressed)
	if continue_button:
		continue_button.pressed.connect(on_continue_pressed)
	if options_button:
		options_button.pressed.connect(on_options_pressed)
	if achievements_button:
		achievements_button.pressed.connect(on_achievements_pressed)
	if exit_button:
		exit_button.pressed.connect(on_exit_pressed)

# Method run when a new game should be created
func on_new_game_pressed():
	pass

# Method run when a game should be resumed
func on_continue_pressed():
	pass

# Method run when user wants to open options menu (settings)
func on_options_pressed():
	pass

# Method run when user wants to open achievements menu
func on_achievements_pressed():
	pass

# Method run when user wants to exit the game
func on_exit_pressed():
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode:
			if animation_player:
				if animation_player.has_animation("menu_in"):
					animation_player.play("menu_in")
			#get_tree().change_scene_to_packed(scene_changer.next_scene)
