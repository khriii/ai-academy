extends Node2D
class_name Graph

# Dimensioni del grafico in pixel
const GRAPH_WIDTH  : float = 600.0
const GRAPH_HEIGHT : float = 400.0
const ORIGIN       : Vector2 = Vector2(300.0, 200.0) # Centro grafico

@onready var prediction_line : Line2D = $PredictionLine
@onready var data_container  : Node2D = $DataPointsContainer

# Parametri della retta: y = slope * x + intercept
var slope     : float = 0.0   # "peso" W
var intercept : float = 0.0   # "bias" B

# Dataset corrente
var data_points : Array[Dictionary] = []
# Ogni punto: { "x": float, "y": float, "label": int (0=blu, 1=rosso) }

# -----------------------------------------------------------
# INIZIALIZZAZIONE
# -----------------------------------------------------------
func setup(dataset: Array[Dictionary]) -> void:
	data_points = dataset
	# Pesi iniziali casuali (il modello non sa niente all'inizio)
	slope     = randf_range(-1.0, 1.0)
	intercept = randf_range(-50.0, 50.0)
	_spawn_data_points()
	_update_prediction_line()

func _spawn_data_points() -> void:
	# Pulisce i vecchi punti
	for child in data_container.get_children():
		child.queue_free()

	for point in data_points:
		var circle = ColorRect.new()
		circle.size = Vector2(12, 12)
		circle.color = Color.RED if point["label"] == 1 else Color.CYAN
		# Converti coordinate dati -> coordinate schermo
		circle.position = data_to_screen(Vector2(point["x"], point["y"])) - Vector2(6, 6)
		data_container.add_child(circle)

# -----------------------------------------------------------
# CONVERSIONE COORDINATE
# Dati: x in [-1, 1], y in [-1, 1]
# Schermo: pixel relativi al nodo Graph
# -----------------------------------------------------------
func data_to_screen(data_pos: Vector2) -> Vector2:
	return Vector2(
		ORIGIN.x + data_pos.x * (GRAPH_WIDTH  / 2.0),
		ORIGIN.y - data_pos.y * (GRAPH_HEIGHT / 2.0)  # Y invertita
	)

# -----------------------------------------------------------
# AGGIORNAMENTO VISIVO DELLA LINEA
# Disegna la retta y = slope*x + intercept
# -----------------------------------------------------------
func _update_prediction_line() -> void:
	var x_start : float = -1.2
	var x_end   : float =  1.2
	var y_start : float = slope * x_start + intercept
	var y_end   : float = slope * x_end   + intercept

	prediction_line.clear_points()
	prediction_line.add_point(data_to_screen(Vector2(x_start, y_start)))
	prediction_line.add_point(data_to_screen(Vector2(x_end,   y_end)))

# -----------------------------------------------------------
# STEP DI TRAINING (chiamato da TrainingSimulator)
# Logica "fake" ma visivamente coerente
# -----------------------------------------------------------
func training_step(learning_rate: float, target_slope: float, target_intercept: float) -> float:
	# Spostiamo slope e intercept verso i valori target
	# Il learning rate controlla QUANTO ci avviciniamo ad ogni step

	var delta_slope     : float = (target_slope     - slope)     * learning_rate
	var delta_intercept : float = (target_intercept - intercept) * learning_rate

	# Learning rate troppo alto → aggiungiamo rumore (la linea "trema")
	if learning_rate > 0.5:
		delta_slope     += randf_range(-0.3, 0.3)
		delta_intercept += randf_range(-0.3, 0.3)

	slope     += delta_slope
	intercept += delta_intercept

	_update_prediction_line()

	# Calcoliamo un'accuracy "fake" basata su quanto siamo vicini al target
	var accuracy : float = _compute_fake_accuracy(target_slope, target_intercept)
	return accuracy

func _compute_fake_accuracy(target_slope: float, target_intercept: float) -> float:
	var slope_error     : float = abs(slope     - target_slope)
	var intercept_error : float = abs(intercept - target_intercept)
	var total_error     : float = (slope_error + intercept_error) / 2.0
	# Trasforma l'errore in accuracy (0.0 → 1.0)
	var accuracy : float = clamp(1.0 - total_error, 0.0, 1.0)
	return accuracy

# -----------------------------------------------------------
# SHAKE EFFECT (learning rate troppo alto)
# -----------------------------------------------------------
func shake(intensity: float = 5.0) -> void:
	var tween = create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "position", offset, 0.05)
	tween.tween_property(self, "position", Vector2.ZERO, 0.05)
