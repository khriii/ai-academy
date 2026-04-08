extends Node2D
class_name TrainingSimulator

# --- Riferimenti nodi ---
@onready var graph          : Graph        = $Graph
@onready var lr_slider      : HSlider      = $ControlPanel/LearningRateSlider
@onready var epoch_slider   : HSlider      = $ControlPanel/EpochSlider
@onready var start_button   : Button       = $ControlPanel/StartButton
@onready var accuracy_bar   : ProgressBar  = $ControlPanel/AccuracyBar
@onready var status_label   : Label        = $ControlPanel/StatusLabel
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
	graph.setup(data["dataset"])
	status_label.text = "Configura i parametri e premi START TRAIN"
	accuracy_bar.value = 0

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	lr_slider.value_changed.connect(_on_lr_changed)

# -----------------------------------------------------------
# AVVIO TRAINING
# -----------------------------------------------------------
func _on_start_pressed() -> void:
	if is_training:
		return
	is_training   = true
	current_epoch = 0
	total_epochs  = int(epoch_slider.value)
	start_button.disabled = true
	status_label.text = "Training in corso..."
	_run_training_loop()

# -----------------------------------------------------------
# LOOP DI TRAINING (asincrono con await)
# -----------------------------------------------------------
func _run_training_loop() -> void:
	var learning_rate      : float = lr_slider.value
	var target_slope       : float = level_data["target_slope"]
	var target_intercept   : float = level_data["target_intercept"]
	var win_threshold      : float = level_data.get("win_threshold", 0.80)

	while current_epoch < total_epochs and is_training:
		current_epoch += 1

		# Effetto shake se LR troppo alto
		if learning_rate > 0.5:
			graph.shake(learning_rate * 10.0)

		# Step di training → ottieni accuracy
		current_accuracy = graph.training_step(learning_rate, target_slope, target_intercept)

		# Aggiorna UI
		accuracy_bar.value = current_accuracy * 100.0
		status_label.text  = "Epoca %d / %d — Accuracy: %.1f%%" % [
			current_epoch, total_epochs, current_accuracy * 100.0
		]

		# Controlla vittoria anticipata
		if current_accuracy >= win_threshold:
			_on_win()
			return

		# Aspetta prima del prossimo step (animazione)
		await get_tree().create_timer(STEP_DELAY).timeout

	# Fine epoche senza vittoria
	_on_training_end()

# -----------------------------------------------------------
# EVENTI
# -----------------------------------------------------------
func _on_win() -> void:
	is_training = false
	start_button.disabled = false
	status_label.text = "✅ Training completato! Accuracy: %.1f%%" % (current_accuracy * 100.0)
	_show_dialogue(level_data.get("win_dialogue", "Ottimo lavoro!"))
	# Emetti segnale per l'Hub (sblocca prossima quest ecc.)
	EventBus.emit_signal("quest_completed", level_data["level_id"])

func _on_training_end() -> void:
	is_training = false
	start_button.disabled = false
	if current_accuracy < level_data.get("win_threshold", 0.80):
		status_label.text = "❌ Non abbastanza preciso. Riprova!"
		_show_dialogue(level_data.get("fail_dialogue", "Riprova con parametri diversi."))

func _on_lr_changed(value: float) -> void:
	# Feedback in tempo reale sullo slider
	if value > 0.5:
		status_label.text = "⚠️ Learning Rate molto alto! La linea potrebbe impazzire."
	elif value < 0.05:
		status_label.text = "🐌 Learning Rate molto basso. Sarà lento..."
	else:
		status_label.text = "✔️ Learning Rate nella norma."

func _show_dialogue(text: String) -> void:
	dialogue_box.visible = true
	dialogue_box.get_node("Label").text = text
