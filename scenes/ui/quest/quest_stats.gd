extends Control

@export var quest_name_label: Label
@export var quest_description_label: Label

var current_quest: Quest = null

func _ready() -> void:
	Global.check_nodes(get_script().get_path(), {
		"quest_name_label": quest_name_label,
		"quest_description_label": quest_description_label,
	})
	
	EventBus.new_quest.connect(set_quest)
	EventBus.quests_updated.connect(change_language)

func set_quest(new_quest: Quest):
	current_quest = new_quest
	change_language()

func change_language():
	if current_quest and quest_name_label and quest_description_label:
		quest_name_label.text = current_quest._name
		quest_description_label.text = current_quest.description
