extends Node2D
class_name TrainingSimulator

signal quest_completed(level_id: String)

# --- Riferimenti nodi ---
@onready var graph         : Graph         = $Graph
@onready var control_panel : ControlPanel  = $ControlPanel
@onready var dialogue_box  : Panel         = $DialogueBox
@onready var close_button: Button = $CloseButton

# --- Stato del training ---
var is_training      : bool  = false
var current_epoch    : int   = 0
var current_accuracy : float = 0.0
var total_epochs     : int   = 0

# --- Dati del livello corrente ---
var level_data : Dictionary = {}

const STEP_DELAY : float = 0.08

func handle_close_button():
	self.queue_free()
# -----------------------------------------------------------
# READY
# -----------------------------------------------------------
func _ready() -> void:
	control_panel.train_requested.connect(_on_train_requested)
	control_panel.training_stopped.connect(_on_training_stopped)
	control_panel.lr_changed.connect(_on_lr_changed)
	close_button.pressed.connect(handle_close_button)

	if level_data.is_empty():
		setup_level(LevelData.get_level("level_2"))
		#await get_tree().create_timer(3.0).timeout
		#unlock_bias()
		#setup_level({
			#"level_id"        : "test_level",
			#"target_slope"    : 1.0,
			#"target_intercept": 0.0,
			#"win_threshold"   : 0.85,
			#"dataset"         : [
				#{"x": -0.8, "y": -0.8, "label": 0},
				#{"x":  0.8, "y":  0.8, "label": 1},
				#{"x": -0.5, "y": -0.3, "label": 0},
				#{"x":  0.5, "y":  0.4, "label": 1},
			#],
			#"win_dialogue" : "Ottimo, il modello si è adattato ai dati!",
			#"fail_dialogue": "Errore troppo alto. Prova a modificare i parametri."
		#})

# -----------------------------------------------------------
# SETUP LIVELLO
# -----------------------------------------------------------
func setup_level(data: Dictionary) -> void:
	level_data = data

	# Setup grafico — dataset training
	graph.setup(data.get("dataset", []))

	# Livello 4 — carica anche il dataset test
	if data.has("dataset_test"):
		graph.setup_test_points(data["dataset_test"])
		graph.overfit_mode = true
	else:
		graph.overfit_mode = false

	# Livello 3 — mostra/nasconde slider bias
	var has_bias : bool = data.has("bias_locked_start")
	control_panel.set_bias_visible(has_bias)
	if has_bias:
		control_panel.reset_bias(data.get("bias_locked_start", true))

	control_panel.set_status("Configura i parametri e premi START TRAIN", Color.WHITE)

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
# LOOP DI TRAINING
# -----------------------------------------------------------
func _run_training_loop(learning_rate: float) -> void:
	var target_slope     : float = level_data.get("target_slope",     1.0)
	var target_intercept : float = level_data.get("target_intercept", 0.0)
	var win_threshold    : float = level_data.get("win_threshold",    0.80)
	var is_overfit       : bool  = level_data.has("dataset_test")

	while current_epoch < total_epochs and is_training:
		current_epoch += 1

		if learning_rate > 0.5 and not is_overfit:
			graph.shake(learning_rate * 10.0)

		# Legge bias dal ControlPanel (0.0 se bloccato o non presente)
		var bias_locked : bool  = control_panel.is_bias_locked()
		var bias_value  : float = control_panel.get_bias_value()

		current_accuracy = graph.training_step(
			learning_rate,
			target_slope,
			target_intercept,
			bias_locked,
			bias_value,
			current_epoch,
			total_epochs
		)

		control_panel.update_progress(current_epoch, total_epochs, current_accuracy)

		# Hint bias livello 3 — suggerisce di parlare con Master Bias
		_check_bias_hint(current_accuracy, target_intercept, bias_locked)

		if current_accuracy >= win_threshold:
			_on_win()
			return

		await get_tree().create_timer(STEP_DELAY).timeout

	if is_training:
		_on_training_end()

# -----------------------------------------------------------
# HINT BIAS (livello 3)
# -----------------------------------------------------------
func _check_bias_hint(accuracy: float, target_intercept: float, bias_locked: bool) -> void:
	if bias_locked and abs(target_intercept) > 0.2 and accuracy < 0.5 and current_epoch > 10:
		control_panel.set_status(
			"💡 La linea non riesce ad allinearsi... forse manca qualcosa?",
			Color(1.0, 0.9, 0.3)
		)

# -----------------------------------------------------------
# SBLOCCO BIAS — chiamato dall'Hub dopo dialogo con Master Bias
# -----------------------------------------------------------
func unlock_bias() -> void:
	control_panel.unlock_bias()

# -----------------------------------------------------------
# EVENTI FINE TRAINING
# -----------------------------------------------------------
func _on_win() -> void:
	is_training = false

	# Livello 4 — rivela i punti viola e confronta accuracy
	if level_data.has("dataset_test"):
		graph.reveal_test_points()
		await get_tree().create_timer(0.8).timeout
		var test_accuracy : float = graph.compute_test_accuracy()
		_handle_overfit_result(current_accuracy, test_accuracy)
		return

	control_panel.show_result(true, current_accuracy)
	_show_dialogue(level_data.get("win_dialogue", "Ottimo lavoro!"))
	quest_completed.emit(level_data.get("level_id", ""))

func _on_training_end() -> void:
	is_training = false

	# Livello 4 — anche se non ha vinto sul training, rivela comunque i test
	if level_data.has("dataset_test"):
		graph.reveal_test_points()
		await get_tree().create_timer(0.8).timeout
		var test_accuracy : float = graph.compute_test_accuracy()
		_handle_overfit_result(current_accuracy, test_accuracy)
		return

	if current_accuracy < level_data.get("win_threshold", 0.80):
		control_panel.show_result(false, current_accuracy)
		_show_dialogue(level_data.get("fail_dialogue", "Riprova con parametri diversi."))
	else:
		_on_win()

# Gestisce il risultato del livello 4 in base al gap train/test
func _handle_overfit_result(train_acc: float, test_acc: float) -> void:
	var gap : float = train_acc - test_acc
	control_panel.show_test_accuracy(train_acc, test_acc)

	if gap > 0.3:
		# Overfit grave — il Mostro ha vinto
		_show_dialogue(
			"Mostro Overfit: Sì! Guarda com'è bella la curva! Ma... quei puntini viola li sbaglio tutti."
		)
	elif test_acc >= level_data.get("win_threshold", 0.70):
		# Buona generalizzazione — vittoria
		_show_dialogue(level_data.get("win_dialogue", "Ottimo lavoro!"))
		quest_completed.emit(level_data.get("level_id", ""))
	else:
		# Non abbastanza buono sul test
		_show_dialogue(level_data.get("fail_dialogue", "Riprova con meno epoche."))

# -----------------------------------------------------------
# CALLBACKS
# -----------------------------------------------------------
func _on_lr_changed(_value: float) -> void:
	pass  # gestito internamente da ControlPanel

func _show_dialogue(text: String) -> void:
	if dialogue_box == null:
		return
	dialogue_box.visible = true
	var label = dialogue_box.get_node_or_null("Label")
	if label != null:
		label.text = text
