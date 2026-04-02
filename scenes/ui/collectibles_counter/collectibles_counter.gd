class_name CollectiblesCounter
extends PanelContainer

@export var collectibles_counter_label: Label

var filename = self.get_script().get_path()

func _ready() -> void:
	check_nodes()
	
	Global.collectibles_updated.connect(_on_collectibles_updated)
	
	set_current_value(Global.collected_collectibles)

func check_nodes():
	if not collectibles_counter_label: Global.print_missing(filename, "collectibles_counter_label")

func _show():
	self.visible = true

func _hide():
	self.visible = false

func set_current_value(new_value: int):
	if collectibles_counter_label:
		collectibles_counter_label.text = str(new_value)

func _on_collectibles_updated(new_total: int):
	set_current_value(new_total)
