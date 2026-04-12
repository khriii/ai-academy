extends PanelContainer

# Variables
@export var button: Button

@export var training_simulator_scene: PackedScene = preload("res://scenes/TrainingSimulator.tscn")


# Methods
func _ready() -> void:
	if button:
		button.pressed.connect(show_training_simulator_ui)


func show_training_simulator_ui():
	var scene = training_simulator_scene.instantiate()
	
	var main_scene = get_tree().current_scene
	var ui_node = main_scene.get_node_or_null("UI")
	
	if ui_node:
		ui_node.add_child(scene)
	else:
		main_scene.add_child(scene)
