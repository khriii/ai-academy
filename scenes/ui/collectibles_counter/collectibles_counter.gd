class_name CollectiblesCounter
extends PanelContainer

@export var collectibles_counter_label: Label

var filename = self.get_script().get_path()


func _ready() -> void:
	Global.check_nodes(filename, {
		"collectibles_counter_label": collectibles_counter_label,
	})
	
	CollectiblesManager.counter_updated.connect(_on_counter_updated)

func _show():
	self.visible = true

func _hide():
	self.visible = false

func set_current_value(new_value: int):
	if collectibles_counter_label:
		collectibles_counter_label.text = str(new_value)

func _on_counter_updated(new_total: int):
	set_current_value(new_total)
