extends Node

var quests: Dictionary = {}
var quests_data: Dictionary = {}

var filename = get_script().get_path()

func _ready() -> void:
	EventBus.language_changed.connect(_on_language_changed)
	load_quests_data()

func load_quests_data() -> void:
	var path = "res://assets/data/%s/quests/quests.json" % Global.current_language
	if not FileAccess.file_exists(path):
		Global.print_error(filename, "Quest file not found: " + path)
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		Global.print_error(filename, "Failed to parse JSON: " + json.get_error_message())
		return
	
	var data = json.get_data()
	if typeof(data) != TYPE_ARRAY:
		Global.print_error(filename, "Invalid quest data format, expected array")
		return
	
	quests_data.clear()
	for quest_entry in data:
		quests_data[quest_entry["id"]] = {
			"name": quest_entry["name"],
			"description": quest_entry["description"]
		}
	
	for quest_id in quests:
		if quests_data.has(quest_id):
			var q = quests[quest_id]
			q._name = quests_data[quest_id]["name"]
			q.description = quests_data[quest_id]["description"]

func _on_language_changed(new_language: String) -> void:
	load_quests_data()

func add_quest(quest_id: String, completed: bool = false) -> bool:
	if quests.has(quest_id):
		Global.print_error(filename, "A quest with that id already exists (" + quest_id + ")")
		return false
	
	if not quests_data.has(quest_id):
		Global.print_error(filename, "Quest data not found for id: " + quest_id)
		return false
	
	var quest_name = quests_data[quest_id]["name"]
	var quest_description = quests_data[quest_id]["description"]
	
	var new_quest = Quest.new(quest_id, quest_name, quest_description, completed)
	quests[quest_id] = new_quest
	EventBus.new_quest.emit(new_quest)
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
			filtered[q.quest_id] = q
	return filtered

func has_quest(quest_id: String) -> bool:
	return quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	return quests[quest_id].completed

func get_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	for q in quests.values():
		save_data[q.quest_id] = {
			"completed": q.completed
		}
	return save_data

func load_save_data(data: Dictionary) -> void:
	quests.clear()
	for quest_id in data:
		if quests_data.has(quest_id):
			var q_data = data[quest_id]
			var quest_name = quests_data[quest_id]["name"]
			var quest_description = quests_data[quest_id]["description"]
			quests[quest_id] = Quest.new(quest_id, quest_name, quest_description, q_data["completed"])
