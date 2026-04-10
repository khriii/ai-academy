class_name GameController
extends Node

# Variables
@export var player: Player
@export var pause_menu: PauseMenu

var filename = get_script().get_path()

# Progressions
enum Progression {
	START,
	TALKED_WITH_DOC_EPOCH,
	TALKED_WITH_LADY_RATE,
	TALKED_WITH_MASTER_BIAS,
	TALKED_WITH_MOSTRO_OVERFITTING,
	ALL_COMPLETED,
}

var current_progression = Progression.START

# Track interaction count for each NPC to show the right stage
var doc_epoch_interactions = 0        # 0-4 interactions (stages 0, 1, 2, 3)
var lady_rate_interactions = 0        # 0-3 interactions (stages 0, 1, 2)
var master_bias_interactions = 0      # 0-3 interactions (stages 0, 1, 2)
var mostro_overfitting_interactions = 0  # 0-2 interactions (stages 0, 1)


# Methods
func load_events() -> void:
	EventBus.npc_interacted.connect(interact_with_npc)
	# TODO: add other events




func interact_with_npc(npc_id: String):
	match npc_id:
		"doc_epoch":
			interact_with_doc_epoch()
		"lady_rate":
			interact_with_lady_rate()
		"master_bias":
			interact_with_master_bias()
		"mostro_overfitting":
			interact_with_mostro_overfitting()


func interact_with_doc_epoch():
	# doc_epoch has 4 stages: 0, 1, 2, 3
	if doc_epoch_interactions == 0:
		# First interaction: introduce epochs
		NpcManager.play_dialog("doc_epoch", 0)
		doc_epoch_interactions += 1
		current_progression = Progression.TALKED_WITH_DOC_EPOCH
	elif doc_epoch_interactions == 1:
		# Second interaction: explain weights
		NpcManager.play_dialog("doc_epoch", 1)
		doc_epoch_interactions += 1
	elif doc_epoch_interactions == 2:
		# Third interaction: see progress
		NpcManager.play_dialog("doc_epoch", 2)
		doc_epoch_interactions += 1
	elif doc_epoch_interactions == 3:
		# Fourth interaction: learning rate hint, unlock Lady Rate
		NpcManager.play_dialog("doc_epoch", 3)
		doc_epoch_interactions += 1
	else:
		# Return dialogue after final interaction
		NpcManager.play_dialog("doc_epoch", 999)


func interact_with_lady_rate():
	# Lady Rate requires doc_epoch stage 3 to be unlocked
	if doc_epoch_interactions < 4:
		NpcManager.play_dialog("lady_rate", 998)  # "parla con doc_epoch prima"
	elif lady_rate_interactions == 0:
		# First interaction: learning rate too high
		NpcManager.play_dialog("lady_rate", 0)
		lady_rate_interactions += 1
		current_progression = Progression.TALKED_WITH_LADY_RATE
	elif lady_rate_interactions == 1:
		# Second interaction: adjust learning rate (too fast, then too slow)
		NpcManager.play_dialog("lady_rate", 1)
		lady_rate_interactions += 1
	elif lady_rate_interactions == 2:
		# Third interaction: perfect learning rate
		NpcManager.play_dialog("lady_rate", 2)
		lady_rate_interactions += 1
	else:
		# Return dialogue after final interaction
		NpcManager.play_dialog("lady_rate", 999)


func interact_with_master_bias():
	# Master Bias requires lady_rate stage 2 to be unlocked
	if lady_rate_interactions < 3:
		NpcManager.play_dialog("master_bias", 998)  # "parla con lady_rate prima"
	elif master_bias_interactions == 0:
		# First interaction: introduce bias concept
		NpcManager.play_dialog("master_bias", 0)
		master_bias_interactions += 1
		current_progression = Progression.TALKED_WITH_MASTER_BIAS
	elif master_bias_interactions == 1:
		# Second interaction: activate bias
		NpcManager.play_dialog("master_bias", 1)
		master_bias_interactions += 1
	elif master_bias_interactions == 2:
		# Third interaction: bias is freedom
		NpcManager.play_dialog("master_bias", 2)
		master_bias_interactions += 1
	else:
		# Return dialogue after final interaction
		NpcManager.play_dialog("master_bias", 999)


func interact_with_mostro_overfitting():
	# Mostro requires master_bias stage 2 to be unlocked
	if master_bias_interactions < 3:
		NpcManager.play_dialog("mostro_overfitting", 998)  # "parla con gli altri insegnanti primo"
	elif mostro_overfitting_interactions == 0:
		# First interaction: 100% accuracy warning
		NpcManager.play_dialog("mostro_overfitting", 0)
		mostro_overfitting_interactions += 1
		current_progression = Progression.TALKED_WITH_MOSTRO_OVERFITTING
	elif mostro_overfitting_interactions == 1:
		# Second interaction: overfitting disaster
		NpcManager.play_dialog("mostro_overfitting", 1)
		mostro_overfitting_interactions += 1
	else:
		# Return dialogue after final interaction
		NpcManager.play_dialog("mostro_overfitting", 999)


func check_pause_menu_pressed(key: String):
	if Input.is_action_just_pressed(key):
		if pause_menu:
			if pause_menu.visible:
				pause_menu._hide()
				get_tree().paused = false
			else:
				pause_menu._show()
				get_tree().paused = true


func _ready() -> void:
	load_events()


func _physics_process(_delta: float) -> void:
	check_pause_menu_pressed("esc")
