extends Node
class_name LevelData

# -----------------------------------------------------------
# Restituisce i dati di configurazione per ogni livello
# -----------------------------------------------------------
static func get_level(level_id: String) -> Dictionary:
	match level_id:

		"level_1":
			return {
				"level_id"        : "level_1",
				"title"           : "La Linea Retta",
				"dataset"         : _generate_linear_dataset(),
				"target_slope"    : 0.8,
				"target_intercept": 0.1,
				"win_threshold"   : 0.80,
				"win_dialogue"    : "Doc. Epoch: Eccellente! I tuoi pesi hanno imparato!",
				"fail_dialogue"   : "Doc. Epoch: Quasi! Riprova con più epoche."
			}

		"level_2":
			return {
				"level_id"        : "level_2",
				"title"           : "Il Salto nel Vuoto",
				"dataset"         : _generate_linear_dataset(),
				"target_slope"    : 0.6,
				"target_intercept": -0.2,
				"win_threshold"   : 0.85,
				"win_dialogue"    : "Lady Rate: Perfetto! Hai trovato il ritmo giusto!",
				"fail_dialogue"   : "Lady Rate: La linea impazzisce! Abbassa il Learning Rate!"
			}

		_:
			push_error("Livello non trovato: " + level_id)
			return {}

# -----------------------------------------------------------
# Generatori di dataset
# -----------------------------------------------------------
static func _generate_linear_dataset() -> Array[Dictionary]:
	var points : Array[Dictionary] = []
	for i in range(20):
		var x     : float = randf_range(-0.9, 0.9)
		var noise : float = randf_range(-0.1, 0.1)
		var y     : float = 0.8 * x + 0.1 + noise
		# Label: 1 (rosso) se sopra la retta, 0 (blu) se sotto
		points.append({
			"x"    : x,
			"y"    : y + randf_range(-0.3, 0.3),
			"label": 1 if randf() > 0.5 else 0
		})
	return points
