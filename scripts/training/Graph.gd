extends Node2D
class_name Graph

# Dimensioni del grafico in pixel — adattate alla tua scena
const GRAPH_WIDTH  : float = 140.0
const GRAPH_HEIGHT : float = 120.0
const ORIGIN       : Vector2 = Vector2(80.0, 80.0)

# Raggio dei punti
const POINT_RADIUS      : float = 5.0
const POINT_RADIUS_TEST : float = 5.0

# Colori
const COLOR_CLASS_0 : Color = Color(0.2, 0.8, 1.0)    # Ciano  — label 0
const COLOR_CLASS_1 : Color = Color(1.0, 0.3, 0.3)    # Rosso  — label 1
const COLOR_TEST    : Color = Color(0.7, 0.3, 1.0)    # Viola  — punti test livello 4
const COLOR_WRONG   : Color = Color(0.35, 0.35, 0.35) # Grigio — classificato male

@onready var prediction_line : Line2D = $PredictionLine
@onready var data_container  : Node2D = $DataPointsContainer

# Parametri della retta: y = slope * x + intercept
var slope     : float = 0.0
var intercept : float = 0.0

# Dataset training
var data_points : Array = []

# Dataset test (livello 4 — punti viola, nascosti fino a reveal_test_points())
var test_points         : Array = []
var test_points_visible : bool  = false

# Stato classificazione per ogni punto training
var _classifications : Array = []

# Modalità overfit (livello 4)
var overfit_mode : bool  = false
var poly_a       : float = 0.0   # coefficiente x³
var poly_b       : float = 0.0   # coefficiente x²

# -----------------------------------------------------------
# INIZIALIZZAZIONE
# -----------------------------------------------------------
func setup(dataset: Array) -> void:
	data_points         = dataset
	test_points         = []
	test_points_visible = false
	overfit_mode        = false
	poly_a              = 0.0
	poly_b              = 0.0

	slope     = randf_range(-1.0, 1.0)
	intercept = randf_range(-0.3, 0.3)  # range sensato, non fuori schermo

	_classifications.resize(data_points.size())
	_classifications.fill(true)

	_spawn_data_points()
	_update_prediction_line()

# Chiamata da TrainingSimulator per il livello 4
func setup_test_points(dataset: Array) -> void:
	test_points = dataset

# -----------------------------------------------------------
# SPAWN PUNTI — ogni punto è un Node2D con _draw via Callable
# -----------------------------------------------------------
func _spawn_data_points() -> void:
	for child in data_container.get_children():
		child.queue_free()

	for i in range(data_points.size()):
		var point  : Dictionary = data_points[i]
		var drawer : Node2D     = Node2D.new()
		drawer.name     = "Point_%d" % i
		drawer.position = data_to_screen(Vector2(point["x"], point["y"]))
		drawer.set_meta("label",   point["label"])
		drawer.set_meta("is_test", false)
		drawer.set_meta("correct", true)
		drawer.connect("draw", _make_draw_callable(drawer))
		data_container.add_child(drawer)
		drawer.queue_redraw()

# Crea la Callable di disegno per un nodo punto
func _make_draw_callable(drawer: Node2D) -> Callable:
	return func():
		var label   : int  = drawer.get_meta("label",   0)
		var is_test : bool = drawer.get_meta("is_test", false)
		var correct : bool = drawer.get_meta("correct", true)

		var fill_color : Color
		if is_test:
			fill_color = COLOR_TEST
		elif not correct:
			fill_color = COLOR_WRONG
		else:
			fill_color = COLOR_CLASS_1 if label == 1 else COLOR_CLASS_0

		var radius : float = POINT_RADIUS_TEST if is_test else POINT_RADIUS

		# Bordo
		drawer.draw_circle(Vector2.ZERO, radius + 1.5, fill_color.lightened(0.4))
		# Riempimento
		drawer.draw_circle(Vector2.ZERO, radius, fill_color)

		# X bianca se classificato male (solo punti training)
		if not correct and not is_test:
			var s : float = radius * 0.7
			drawer.draw_line(Vector2(-s, -s), Vector2( s,  s), Color.WHITE, 1.5)
			drawer.draw_line(Vector2( s, -s), Vector2(-s,  s), Color.WHITE, 1.5)

# -----------------------------------------------------------
# CONVERSIONE COORDINATE
# -----------------------------------------------------------
func data_to_screen(data_pos: Vector2) -> Vector2:
	return Vector2(
		ORIGIN.x + data_pos.x * (GRAPH_WIDTH  / 2.0),
		ORIGIN.y - data_pos.y * (GRAPH_HEIGHT / 2.0)
	)

# -----------------------------------------------------------
# AGGIORNAMENTO LINEA
# Modalità normale → 2 punti (retta)
# Modalità overfit  → 40 punti campionati (curva polinomiale)
# -----------------------------------------------------------
func _update_prediction_line() -> void:
	prediction_line.clear_points()

	var steps : int   = 2 if not overfit_mode else 40
	var x_min : float = -1.2
	var x_max : float =  1.2

	for i in range(steps + 1):
		var t : float = float(i) / float(steps)
		var x : float = lerp(x_min, x_max, t)
		var y : float = _predict(x)
		prediction_line.add_point(data_to_screen(Vector2(x, y)))

# Predizione — retta normale o polinomio overfit
func _predict(x: float) -> float:
	if overfit_mode:
		return poly_a * x * x * x + poly_b * x * x + slope * x + intercept
	else:
		return slope * x + intercept

# -----------------------------------------------------------
# AGGIORNA CLASSIFICAZIONE — ridisegna i punti con colore corretto
# -----------------------------------------------------------
func _update_point_classifications() -> void:
	var children : Array = data_container.get_children()
	for i in range(data_points.size()):
		if i >= children.size():
			break
		var point       : Dictionary = data_points[i]
		var predicted_y : float      = _predict(point["x"])
		var above_line  : bool       = point["y"] > predicted_y
		var correct     : bool       = (point["label"] == 1 and above_line) or \
									   (point["label"] == 0 and not above_line)
		_classifications[i] = correct
		var drawer : Node2D = children[i]
		drawer.set_meta("correct", correct)
		drawer.queue_redraw()

# -----------------------------------------------------------
# RIVELA PUNTI TEST (livello 4)
# Chiamata da TrainingSimulator a fine training
# -----------------------------------------------------------
func reveal_test_points() -> void:
	test_points_visible = true
	for point in test_points:
		var drawer : Node2D = Node2D.new()
		drawer.position = data_to_screen(Vector2(point["x"], point["y"]))
		drawer.set_meta("label",   point["label"])
		drawer.set_meta("is_test", true)
		drawer.set_meta("correct", true)
		drawer.connect("draw", _make_draw_callable(drawer))
		data_container.add_child(drawer)
		drawer.queue_redraw()
		# Animazione apparizione in dissolvenza
		drawer.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(drawer, "modulate:a", 1.0, 0.5)

# Calcola accuracy sui punti test
func compute_test_accuracy() -> float:
	if test_points.is_empty():
		return 0.0
	var correct_count : int = 0
	for point in test_points:
		var predicted_y : float = _predict(point["x"])
		var above_line  : bool  = point["y"] > predicted_y
		var correct     : bool  = (point["label"] == 1 and above_line) or \
								   (point["label"] == 0 and not above_line)
		if correct:
			correct_count += 1
	return float(correct_count) / float(test_points.size())

# -----------------------------------------------------------
# STEP DI TRAINING — entry point unico
# bias_locked  : intercept forzato a 0 (livello 3)
# bias_value   : valore slider Bias (livello 3, solo se sbloccato)
# epoch        : epoca corrente (livello 4)
# total_epochs : epoche totali  (livello 4)
# -----------------------------------------------------------
func training_step(
	learning_rate    : float,
	target_slope     : float,
	target_intercept : float,
	bias_locked      : bool  = true,
	bias_value       : float = 0.0,
	epoch            : int   = 0,
	total_epochs     : int   = 1
) -> float:
	if overfit_mode:
		return _training_step_overfit(learning_rate, target_slope, target_intercept, epoch, total_epochs)
	else:
		return _training_step_normal(learning_rate, target_slope, target_intercept, bias_locked, bias_value)

# --- Modalità normale (livelli 1, 2, 3) ---
func _training_step_normal(
	learning_rate    : float,
	target_slope     : float,
	target_intercept : float,
	bias_locked      : bool,
	bias_value       : float
) -> float:
	if learning_rate > 0.5:
		# Overshoot: la linea rimbalza oltre il target
		var overshoot : float = 1.0 + (learning_rate - 0.5) * 4.0
		slope     += (target_slope     - slope)     * learning_rate * overshoot * randf_range(-1.0, 1.0)
		intercept += (target_intercept - intercept) * learning_rate * overshoot * randf_range(-1.0, 1.0)
	else:
		slope += (target_slope - slope) * learning_rate
		if bias_locked:
			intercept = 0.0   # bloccato → passa per l'origine
		else:
			intercept = bias_value   # il giocatore controlla

	_update_prediction_line()
	_update_point_classifications()
	return _compute_fake_accuracy(target_slope, target_intercept, bias_locked)

# --- Modalità overfit (livello 4) ---
func _training_step_overfit(
	learning_rate    : float,
	target_slope     : float,
	target_intercept : float,
	epoch            : int,
	total_epochs     : int
) -> float:
	# La retta converge normalmente
	slope     += (target_slope     - slope)     * learning_rate
	intercept += (target_intercept - intercept) * learning_rate

	# Con le epoche la curva si torce sempre di più
	var overfit_factor : float = float(epoch) / float(max(total_epochs, 1))
	poly_b = sin(overfit_factor * PI * 2.0) * overfit_factor * 0.8
	poly_a = cos(overfit_factor * PI * 3.0) * overfit_factor * 0.5

	_update_prediction_line()
	_update_point_classifications()

	# Training accuracy sale sempre (overfit), test accuracy crolla
	return clamp(0.5 + overfit_factor * 0.5, 0.0, 1.0)

# -----------------------------------------------------------
# ACCURACY FAKE (modalità normale)
# -----------------------------------------------------------
func _compute_fake_accuracy(
	target_slope     : float,
	target_intercept : float,
	bias_locked      : bool = true
) -> float:
	var slope_error     : float = abs(slope     - target_slope)
	var intercept_error : float = abs(intercept - target_intercept)
	var total_error     : float = (slope_error + intercept_error) / 2.0
	var accuracy        : float = clamp(1.0 - total_error, 0.0, 1.0)

	# Tetto artificiale se bias bloccato e serve intercept alto (livello 3)
	if bias_locked and abs(target_intercept) > 0.2:
		var max_reachable : float = 1.0 - abs(target_intercept) * 0.8
		accuracy = min(accuracy, max_reachable)

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
