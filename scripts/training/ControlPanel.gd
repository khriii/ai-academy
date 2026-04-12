extends VBoxContainer
class_name ControlPanel

# -----------------------------------------------------------
# Segnali
# -----------------------------------------------------------
signal train_requested(params: Dictionary)
signal training_stopped()
signal lr_changed(value: float)

# --- Riferimenti nodi ---
@onready var lr_value_label    : Label       = $LRValueLabel
@onready var lr_slider         : HSlider     = $LearningRateSlider
@onready var epoch_value_label : Label       = $EpochValueLabel
@onready var epoch_slider      : HSlider     = $EpochSlider
@onready var bias_title_label  : Label       = $BiasTitleLabel
@onready var bias_value_label  : Label       = $BiasValueLabel
@onready var bias_slider       : HSlider     = $BiasSlider
@onready var start_button      : Button      = $StartButton
@onready var stop_button       : Button      = $StopButton
@onready var accuracy_bar      : ProgressBar = $AccuracyBar
@onready var status_label      : Label       = $StatusLabel
@onready var hint_label        : Label       = $HintLabel

# --- Stato interno ---
var _is_training : bool = false
var _bias_locked : bool = true

# -----------------------------------------------------------
# READY
# -----------------------------------------------------------
func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	lr_slider.value_changed.connect(_on_lr_changed)
	epoch_slider.value_changed.connect(_on_epoch_changed)
	bias_slider.value_changed.connect(_on_bias_changed)

	stop_button.visible       = false
	accuracy_bar.value        = 0
	_set_bias_nodes_visible(false)
	bias_slider.editable      = false

	_update_lr_label(lr_slider.value)
	_update_epoch_label(epoch_slider.value)
	_update_bias_label(bias_slider.value)
	set_status("Configura i parametri e premi START TRAIN", Color.WHITE)

# -----------------------------------------------------------
# BOTTONI
# -----------------------------------------------------------
func _on_start_pressed() -> void:
	if _is_training:
		return
	_set_training_mode(true)
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
	if value >= 0.7:
		set_hint("⚠️ Troppo veloce! La linea impazzirà.", Color(1.0, 0.4, 0.4))
	elif value >= 0.4:
		set_hint("⚡ Alto. Potrebbe non convergere.", Color(1.0, 0.8, 0.2))
	elif value <= 0.2:
		set_hint("🐌 Molto lento. Servono tante epoche.", Color(0.6, 0.8, 1.0))
	else:
		set_hint("✔️ Nella norma. Buona scelta.", Color(0.4, 1.0, 0.6))

func _on_epoch_changed(value: float) -> void:
	_update_epoch_label(value)

func _on_bias_changed(value: float) -> void:
	_update_bias_label(value)

# -----------------------------------------------------------
# API PUBBLICA — TrainingSimulator
# -----------------------------------------------------------
func update_progress(epoch: int, total: int, accuracy: float) -> void:
	accuracy_bar.value = accuracy * 100.0
	set_status(
		"Epoca %d / %d  —  Accuracy: %.1f%%" % [epoch, total, accuracy * 100.0],
		Color.WHITE
	)

func show_result(success: bool, accuracy: float) -> void:
	_set_training_mode(false)
	if success:
		set_status("✅ Completato! Accuracy: %.1f%%" % (accuracy * 100.0), Color(0.4, 1.0, 0.6))
	else:
		set_status("❌ Non abbastanza. Riprova!", Color(1.0, 0.4, 0.4))

# Livello 4 — mostra train e test accuracy a confronto
func show_test_accuracy(train_acc: float, test_acc: float) -> void:
	_set_training_mode(false)
	var gap : float = train_acc - test_acc
	if gap > 0.3:
		set_status(
			"Training: %.0f%%  |  Test: %.0f%%  ← Overfit!" % [train_acc * 100.0, test_acc * 100.0],
			Color(1.0, 0.4, 0.4)
		)
		set_hint("Hai addestrato troppo! La curva ha memorizzato i dati.", Color(1.0, 0.4, 0.4))
	else:
		set_status(
			"Training: %.0f%%  |  Test: %.0f%%  ✔️" % [train_acc * 100.0, test_acc * 100.0],
			Color(0.4, 1.0, 0.6)
		)
		set_hint("Buona generalizzazione! Il modello capisce davvero.", Color(0.4, 1.0, 0.6))

func set_controls_locked(locked: bool) -> void:
	start_button.disabled = locked
	lr_slider.editable    = not locked
	epoch_slider.editable = not locked

# -----------------------------------------------------------
# API BIAS (livello 3)
# -----------------------------------------------------------
func set_bias_visible(visible_state: bool) -> void:
	_set_bias_nodes_visible(visible_state)

func reset_bias(locked: bool) -> void:
	_bias_locked          = locked
	bias_slider.value     = 0.0
	bias_slider.editable  = not locked
	_update_bias_label(0.0)
	# Titolo mostra lo stato del lock
	bias_title_label.text = "Bias: 🔒" if locked else "Bias: 🔓"

func unlock_bias() -> void:
	_bias_locked          = false
	bias_slider.editable  = true
	bias_title_label.text = "Bias: 🔓"
	set_status("Master Bias ha sbloccato il parametro Bias!", Color(1.0, 0.8, 0.2))

func is_bias_locked() -> bool:
	return _bias_locked

func get_bias_value() -> float:
	return bias_slider.value if not _bias_locked else 0.0

# -----------------------------------------------------------
# HELPERS PRIVATI
# -----------------------------------------------------------
func _set_bias_nodes_visible(v: bool) -> void:
	bias_title_label.visible = v
	bias_value_label.visible = v
	bias_slider.visible      = v

func _set_training_mode(training: bool) -> void:
	_is_training          = training
	start_button.visible  = not training
	stop_button.visible   = training
	lr_slider.editable    = not training
	epoch_slider.editable = not training
	if not _bias_locked:
		bias_slider.editable = not training

func _update_lr_label(value: float) -> void:
	lr_value_label.text = "%.3f" % value

func _update_epoch_label(value: float) -> void:
	epoch_value_label.text = "%d" % int(value)

func _update_bias_label(value: float) -> void:
	bias_value_label.text = "%.2f" % value

func set_status(text: String, color: Color = Color.WHITE) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)

func set_hint(text: String, color: Color = Color.WHITE) -> void:
	hint_label.text = text
	hint_label.add_theme_color_override("font_color", color)
