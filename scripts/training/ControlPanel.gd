extends VBoxContainer
class_name ControlPanel

# -----------------------------------------------------------
# Segnali — TrainingSimulator si connette a questi
# -----------------------------------------------------------
signal train_requested(params: Dictionary)
signal training_stopped()
signal lr_changed(value: float)

# --- Riferimenti nodi (struttura in ControlPanel.tscn) ---
@onready var lr_slider        : HSlider     = $LearningRateSlider
@onready var lr_value_label   : Label       = $LRValueLabel
@onready var epoch_slider     : HSlider     = $EpochSlider
@onready var epoch_value_label: Label       = $EpochValueLabel
@onready var start_button     : Button      = $StartButton
@onready var stop_button      : Button      = $StopButton
@onready var accuracy_bar     : ProgressBar = $AccuracyBar
@onready var status_label     : Label       = $StatusLabel
@onready var hint_label       : Label       = $HintLabel

# --- Stato interno ---
var _is_training : bool = false

# -----------------------------------------------------------
# READY
# -----------------------------------------------------------
func _ready() -> void:
	# Connessioni UI
	
	print(start_button)
	
	start_button.pressed.connect(_on_start_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	lr_slider.value_changed.connect(_on_lr_changed)
	epoch_slider.value_changed.connect(_on_epoch_changed)

	# Stato iniziale
	stop_button.visible  = false
	accuracy_bar.value   = 0
	_update_lr_label(lr_slider.value)
	_update_epoch_label(epoch_slider.value)
	set_status("Configura i parametri e premi START TRAIN", Color.WHITE)

func _on_start_pressed() -> void:
	if _is_training:
		return
	_set_training_mode(true)
	# Raccoglie tutti i parametri e li manda al Simulator
	train_requested.emit({
		"learning_rate" : lr_slider.value,
		"epochs"        : int(epoch_slider.value),
	})

func _on_stop_pressed() -> void:
	training_stopped.emit()
	_set_training_mode(false)
	set_status("Training interrotto.", Color.YELLOW)

# -----------------------------------------------------------
# SLIDER CALLBACKS
# -----------------------------------------------------------
func _on_lr_changed(value: float) -> void:
	_update_lr_label(value)
	lr_changed.emit(value)

	# Feedback contestuale in tempo reale
	if value >= 0.7:
		set_hint("⚠️ Troppo veloce! La linea impazzirà.", Color(1.0, 0.4, 0.4))
	elif value >= 0.4:
		set_hint("⚡ Alto. Potrebbe non convergere.", Color(1.0, 0.8, 0.2))
	elif value <= 0.01:
		set_hint("🐌 Molto lento. Servono tante epoche.", Color(0.6, 0.8, 1.0))
	else:
		set_hint("✔️ Nella norma. Buona scelta.", Color(0.4, 1.0, 0.6))

func _on_epoch_changed(value: float) -> void:
	_update_epoch_label(value)

# -----------------------------------------------------------
# API PUBBLICA — chiamata da TrainingSimulator
# -----------------------------------------------------------

# Aggiorna la barra e la label di stato ad ogni epoca
func update_progress(epoch: int, total: int, accuracy: float) -> void:
	accuracy_bar.value = accuracy * 100.0
	set_status(
		"Epoca %d / %d  —  Accuracy: %.1f%%" % [epoch, total, accuracy * 100.0],
		Color.WHITE
	)

# Mostra il risultato finale
func show_result(success: bool, accuracy: float) -> void:
	_set_training_mode(false)
	if success:
		set_status("✅ Completato! Accuracy: %.1f%%" % (accuracy * 100.0), Color(0.4, 1.0, 0.6))
	else:
		set_status("❌ Non abbastanza. Riprova!", Color(1.0, 0.4, 0.4))

# Blocca/sblocca tutti i controlli (es. durante un dialogo NPC)
func set_controls_locked(locked: bool) -> void:
	start_button.disabled  = locked
	lr_slider.editable     = not locked
	epoch_slider.editable  = not locked

# -----------------------------------------------------------
# HELPERS PRIVATI
# -----------------------------------------------------------
func _set_training_mode(training: bool) -> void:
	_is_training           = training
	start_button.visible   = not training
	stop_button.visible    = training
	lr_slider.editable     = not training
	epoch_slider.editable  = not training

func _update_lr_label(value: float) -> void:
	lr_value_label.text = "%.3f" % value

func _update_epoch_label(value: float) -> void:
	epoch_value_label.text = "%d" % int(value)

func set_status(text: String, color: Color = Color.WHITE) -> void:
	status_label.text            = text
	status_label.add_theme_color_override("font_color", color)

func set_hint(text: String, color: Color = Color.WHITE) -> void:
	hint_label.text = text
	hint_label.add_theme_color_override("font_color", color)
