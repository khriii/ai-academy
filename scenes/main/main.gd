extends Node2D

@export var player: Player
@export var pause_menu: PauseMenu

var filename = get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"player": player,
		"pause_menu": pause_menu,
	})

func check_esc_pressed():
	if Input.is_action_just_pressed("esc"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu._hide()
				get_tree().paused = false
			else:
				pause_menu._show()
				get_tree().paused = true


func _physics_process(_delta: float) -> void:
	check_esc_pressed()
