extends Node

# Variables
const SAVE_PATH: String = "user://save_data.json"

# Methods
func save_game() -> void:
	var global_save_data: Dictionary = {
		"npcs": NpcManager.get_save_data(),
		"collectibles": CollectiblesManager.get_save_data(),
		"quests": QuestManager.get_save_data()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(global_save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Saved succesfully.")
	else:
		Global.print_error(get_script().get_path(), "Error during saving")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		Global.print_error(get_script().get_path(), "Save file not found")
		print("Nessun file di salvataggio trovato.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var global_save_data = json.data
			_distribute_loaded_data(global_save_data)
			print("Partita caricata con successo.")
		else:
			printerr("Errore durante il parsing del JSON di salvataggio.")
	else:
		printerr("Errore: impossibile leggere il file di salvataggio.")

func _distribute_loaded_data(data: Dictionary) -> void:
	if data.has("npcs"):
		NpcManager.load_save_data(data["npcs"])
		
	if data.has("collectibles"):
		CollectiblesManager.load_save_data(data["collectibles"])
		
	if data.has("quests"):
		QuestManager.load_save_data(data["quests"])
		
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Salvataggio eliminato.")
