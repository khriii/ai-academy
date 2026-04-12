extends Node2D
class_name TrainingSimulator

# --- Riferimenti nodi ---
@onready var graph          : Graph        = $Graph
@onready var control_panel  : ControlPanel = $ControlPanel
@onready var dialogue_box   : Panel        = $DialogueBox

# --- Stato del training ---
var is_training      : bool  = false
var current_epoch    : int   = 0
var current_accuracy : float = 0.0
var total_epochs     : int   = 0

# --- Dati del livello corrente ---
var level_data : Dictionary = {}

# Tempo tra uno step e l'altro (in secondi) — dà l'effetto animato
const STEP_DELAY : float = 0.08

# -----------------------------------------------------------
# SETUP — chiamato dall'Hub quando carica questa scena
# -----------------------------------------------------------
func setup_level(data: Dictionary) -> void:
	level_data = data
	graph.setup(data.get("dataset", []))
	control_panel.set_status("Configura i parametri e premi START TRAIN", Color.WHITE)

func _ready() -> void:
	control_panel.train_requested.connect(_on_train_requested)
	control_panel.training_stopped.connect(_on_training_stopped)
	control_panel.lr_changed.connect(_on_lr_changed)

	# Controllo per l'avvio in modalità standalone (DEBUG)
	if level_data.is_empty():
		# Dati simulati di fallback
		setup_level({
			"level_id": "test_level",
			"target_slope": 1.0,
			"target_intercept": 0.0,
			"win_threshold": 0.85,
			"dataset": [
				{"x": -0.8, "y": -0.8, "label": 0},
				{"x": 0.8, "y": 0.8, "label": 1},
				{"x": -0.5, "y": -0.3, "label": 0},
				{"x": 0.5, "y": 0.4, "label": 1}
			],
			"win_dialogue": "Ottimo, il modello si è adattato ai dati!",
			"fail_dialogue": "Errore troppo alto. Prova a modificare i parametri."
		})

# -----------------------------------------------------------
# AVVIO TRAINING
# -----------------------------------------------------------
func _on_train_requested(params: Dictionary) -> void:
	if is_training:
		return
	is_training   = true
	current_epoch = 0
	total_epochs  = params["epochs"]
	
	control_panel.set_status("Training in corso...", Color.WHITE)
	_run_training_loop(params["learning_rate"])

func _on_training_stopped() -> void:
	is_training = false

# -----------------------------------------------------------
# LOOP DI TRAINING (asincrono con await)
# -----------------------------------------------------------
func _run_training_loop(learning_rate: float) -> void:
	var target_slope       : float = level_data.get("target_slope", 1.0)
	var target_intercept   : float = level_data.get("target_intercept", 0.0)
	var win_threshold      : float = level_data.get("win_threshold", 0.80)

	while current_epoch < total_epochs and is_training:
		current_epoch += 1

		# Effetto shake se LR troppo alto
		if learning_rate > 0.5:
			graph.shake(learning_rate * 10.0)

		# Step di training → ottieni accuracy
		current_accuracy = graph.training_step(learning_rate, target_slope, target_intercept)

		# Aggiorna UI
		control_panel.update_progress(current_epoch, total_epochs, current_accuracy)

		# Controlla vittoria anticipata
		if current_accuracy >= win_threshold:
			_on_win()
			return

		# Aspetta prima del prossimo step (animazione)
		await get_tree().create_timer(STEP_DELAY).timeout

	if is_training:
		# Fine epoche senza vittoria
		_on_training_end()

# -----------------------------------------------------------
# EVENTI
# -----------------------------------------------------------
func _on_win() -> void:
	is_training = false
	control_panel.show_result(true, current_accuracy)
	_show_dialogue(level_data.get("win_dialogue", "Ottimo lavoro!"))
	
	# Emetti segnale per l'Hub (sblocca prossima quest ecc.) se EventBus esiste
	if ClassDB.class_exists("EventBus") and get_node_or_null("/root/EventBus"):
		get_node("/root/EventBus").emit_signal("quest_completed", level_data.get("level_id", ""))

func _on_training_end() -> void:
	is_training = false
	if current_accuracy < level_data.get("win_threshold", 0.80):
		control_panel.show_result(false, current_accuracy)
		_show_dialogue(level_data.get("fail_dialogue", "Riprova con parametri diversi."))
	else:
		_on_win()

func _on_lr_changed(value: float) -> void:
	# Gestito internamente da ControlPanel, utile se in futuro si vuol fare emit o altro da Simulator
	pass

func _show_dialogue(text: String) -> void:
	if dialogue_box != null:
		dialogue_box.visible = true
		var label = dialogue_box.get_node_or_null("Label")
		if label != null:
			label.text = text
