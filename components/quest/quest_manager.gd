extends Node

# Variables
var quests: Dictionary = {}

var filename = get_script().get_path()

# Methods
func add_quest(quest: Quest) -> bool:
	if quests.has(quest.id):
		Global.print_error(filename, "A quest with that id already exist (" + quest.id + ")")
		return false
	quests[quest.id] = quest
	return true

func remove_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		Global.print_error(filename, "A quest with that id does not exist (" + quest_id + ")")
		return false
	quests.erase(quest_id)
	return true

func complete_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		Global.print_error(filename, "A quest with that id does not exist (" + quest_id + ")")
		return false
	quests[quest_id].complete()
	return true

func get_quest(quest_id: String) -> Quest:
	if not quests.has(quest_id):
		Global.print_error(filename, "A quest with that id does not exist (" + quest_id + ")")
		return null
	return quests[quest_id]

func get_all_quests() -> Dictionary:
	return quests

func get_quests(completed: bool) -> Dictionary:
	var filtered: Dictionary = {}
	for q in quests.values():
		if q.completed == completed:
			filtered[q.id] = q
	return filtered

func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	for q in quests.values():
		save_data[q.id] = {
			"name": q._name,
			"description": q.description,
			"completed": q.completed
		}
	return save_data

func load_save_data(data: Dictionary) -> void:
	quests.clear()
	for quest_id in data:
		var q_data = data[quest_id]
		quests[quest_id] = Quest.new(quest_id, q_data["name"], q_data["description"], q_data["completed"])
