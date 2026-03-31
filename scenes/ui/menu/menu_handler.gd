extends Node2D

@export var scene_changer: SceneChanger
@export var animation_player: AnimationPlayer

var filename = "menu_hgandler.gd"

func print_error(error_message):
	print(filename + ": " + error_message)

func check_nodes():
	if not animation_player: print_error("animation_player missing")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode:
			if animation_player:
				if animation_player.has_animation("menu_in"):
					animation_player.play("menu_in")
			#get_tree().change_scene_to_packed(scene_changer.next_scene)
