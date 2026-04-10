extends Control

@export var quest_name_label: Label
@export var quest_description_label: Label

func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"quest_name_label": quest_name_label,
		"quest_description_label": quest_description_label,
	})
	
	EventBus.new_quest.connect(set_quest)

func set_quest(new_quest: Quest):
	if quest_name_label and quest_description_label:
		quest_name_label.text = new_quest._name
		quest_description_label.text = new_quest.description
