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

		"level_3":
			return {
				"level_id"          : "level_3",
				"title"             : "Il Correttore",
				"dataset"           : _generate_biased_dataset(),
				"target_slope"      : 0.5,
				"target_intercept"  : 0.6,
				"bias_locked_start" : true,
				"win_threshold"     : 0.82,
				"win_dialogue"      : "Master Bias: Ecco. Ora la linea può muoversi dove serve.",
				"fail_dialogue"     : "Master Bias: Senza bias, la linea è costretta. Parla con me."
			}

		"level_4":
			var datasets = _generate_overfit_datasets()
			return {
				"level_id"      : "level_4",
				"title"         : "Non Imparare a Memoria!",
				"dataset"       : datasets["train"],
				"dataset_test"  : datasets["test"],
				"target_slope"  : 0.7,
				"target_intercept": 0.0,
				"win_threshold" : 0.70,   # soglia sul test set, non sul training
				"win_dialogue"  : "Doc. Epoch: Hai capito la lezione più importante. Generalizzare, non memorizzare.",
				"fail_dialogue" : "Mostro Overfit: La curva è bellissima... ma inutile fuori da qui. Riprova con meno epoche."
			}

		_:
			push_error("Livello non trovato: " + level_id)
			return {}

# -----------------------------------------------------------
# GENERATORI DI DATASET
# -----------------------------------------------------------

# Livelli 1 e 2 — distribuzione lineare attorno all'origine
static func _generate_linear_dataset() -> Array[Dictionary]:
	var points : Array[Dictionary] = []
	for i in range(20):
		var x     : float = randf_range(-0.9, 0.9)
		var noise : float = randf_range(-0.1, 0.1)
		var y     : float = 0.8 * x + 0.1 + noise
		points.append({
			"x"    : x,
			"y"    : y + randf_range(-0.15, 0.15),
			"label": 1 if y > 0.1 else 0
		})
	return points

# Livello 3 — dati shiftati verso l'alto (intercept = 0.6)
# Senza bias la linea non converge mai
static func _generate_biased_dataset() -> Array[Dictionary]:
	var points : Array[Dictionary] = []
	for i in range(20):
		var x : float = randf_range(-0.9, 0.9)
		var y : float = 0.5 * x + 0.6 + randf_range(-0.1, 0.1)
		points.append({
			"x"    : x,
			"y"    : y,
			"label": 1 if y > 0.6 else 0
		})
	return points

# Livello 4 — due dataset separati: training (verde) e test (viola)
# I punti training sono pochi e rumorosi → facili da memorizzare
# I punti test sono distribuiti regolarmente → difficili da generalizzare
static func _generate_overfit_datasets() -> Dictionary:
	var train : Array[Dictionary] = []
	var test  : Array[Dictionary] = []

	# Training: 12 punti con rumore alto → la curva li memorizza facilmente
	for i in range(12):
		var x : float = randf_range(-0.9, 0.9)
		var y : float = 0.7 * x + randf_range(-0.4, 0.4)  # rumore alto
		train.append({
			"x"    : x,
			"y"    : y,
			"label": 1 if y > 0.0 else 0
		})

	# Test: 15 punti distribuiti regolarmente, rumore basso
	for i in range(15):
		var x : float = lerp(-0.9, 0.9, float(i) / 14.0)
		var y : float = 0.7 * x + randf_range(-0.1, 0.1)  # rumore basso
		test.append({
			"x"    : x,
			"y"    : y,
			"label": 1 if y > 0.0 else 0
		})

	return {"train": train, "test": test}
