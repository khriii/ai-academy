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
var doc_epoch_interactions = 0
var lady_rate_interactions = 0
var master_bias_interactions = 0
var mostro_overfitting_interactions = 0

# Track which quests have been given
var quest_given_start = false
var quest_given_doc_epoch = false
var quest_given_lady_rate = false
var quest_given_master_bias = false
var quest_given_mostro_overfitting = false

# Methods
func load_events() -> void:
	EventBus.npc_interacted.connect(interact_with_npc)

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

func _create_quest(quest_id: String, quest_name: String, quest_description: String, completed: bool = false) -> void:
	var new_quest = Quest.new(quest_id, quest_name, quest_description, completed)
	EventBus.new_quest.emit(new_quest)

func _give_start_quest():
	if not quest_given_start:
		_create_quest(
			"talk_with_doc_epoch",
			"Parla con Doc Epoch",
			"Trova Doc Epoch e parla con lui per iniziare il tuo viaggio nel machine learning."
		)
		quest_given_start = true

func interact_with_doc_epoch():
	if doc_epoch_interactions == 0:
		NpcManager.play_dialog("doc_epoch", 0)
		doc_epoch_interactions += 1
		current_progression = Progression.TALKED_WITH_DOC_EPOCH
		
		if not quest_given_doc_epoch:
			_create_quest(
				"talk_with_doc_epoch",
				"Parla con Doc Epoch",
				"Doc Epoch ti spiegherà come funzionano le epoche durante l'addestramento del modello."
			)
			quest_given_doc_epoch = true
			EventBus.quest_completed.emit("talk_with_doc_epoch")
			
	elif doc_epoch_interactions == 1:
		NpcManager.play_dialog("doc_epoch", 1)
		doc_epoch_interactions += 1
	elif doc_epoch_interactions == 2:
		NpcManager.play_dialog("doc_epoch", 2)
		doc_epoch_interactions += 1
	elif doc_epoch_interactions == 3:
		NpcManager.play_dialog("doc_epoch", 3)
		doc_epoch_interactions += 1
		
		_create_quest(
			"talk_with_lady_rate",
			"Parla con Lady Rate",
			"Doc Epoch ti ha detto di parlare con Lady Rate per imparare a regolare il learning rate.",
			false
		)
		EventBus.quest_completed.emit("talk_with_doc_epoch")
		
	else:
		NpcManager.play_dialog("doc_epoch", 999)

func interact_with_lady_rate():
	if doc_epoch_interactions < 4:
		NpcManager.play_dialog("lady_rate", 998)
	elif lady_rate_interactions == 0:
		NpcManager.play_dialog("lady_rate", 0)
		lady_rate_interactions += 1
		current_progression = Progression.TALKED_WITH_LADY_RATE
		
		if not quest_given_lady_rate:
			_create_quest(
				"talk_with_lady_rate",
				"Parla con Lady Rate",
				"Lady Rate ti aiuterà a capire come scegliere il giusto learning rate per il tuo modello."
			)
			quest_given_lady_rate = true
			EventBus.quest_completed.emit("talk_with_lady_rate")
			
	elif lady_rate_interactions == 1:
		NpcManager.play_dialog("lady_rate", 1)
		lady_rate_interactions += 1
	elif lady_rate_interactions == 2:
		NpcManager.play_dialog("lady_rate", 2)
		lady_rate_interactions += 1
		
		_create_quest(
			"talk_with_master_bias",
			"Parla con Master Bias",
			"Lady Rate ti ha detto di parlare con Master Bias per capire il ruolo del bias nel modello.",
			false
		)
		EventBus.quest_completed.emit("talk_with_lady_rate")
		
	else:
		NpcManager.play_dialog("lady_rate", 999)

func interact_with_master_bias():
	if lady_rate_interactions < 3:
		NpcManager.play_dialog("master_bias", 998)
	elif master_bias_interactions == 0:
		NpcManager.play_dialog("master_bias", 0)
		master_bias_interactions += 1
		current_progression = Progression.TALKED_WITH_MASTER_BIAS
		
		if not quest_given_master_bias:
			_create_quest(
				"talk_with_master_bias",
				"Parla con Master Bias",
				"Master Bias ti spiegherà come il bias aiuta il modello a fare previsioni migliori."
			)
			quest_given_master_bias = true
			EventBus.quest_completed.emit("talk_with_master_bias")
			
	elif master_bias_interactions == 1:
		NpcManager.play_dialog("master_bias", 1)
		master_bias_interactions += 1
	elif master_bias_interactions == 2:
		NpcManager.play_dialog("master_bias", 2)
		master_bias_interactions += 1
		
		_create_quest(
			"talk_with_mostro_overfitting",
			"Parla con il Mostro Overfitting",
			"Master Bias ti avverte: è ora di parlare con il Mostro Overfitting per evitare la trappola del troppo apprendimento.",
			false
		)
		EventBus.quest_completed.emit("talk_with_master_bias")
		
	else:
		NpcManager.play_dialog("master_bias", 999)

func interact_with_mostro_overfitting():
	if master_bias_interactions < 3:
		NpcManager.play_dialog("mostro_overfitting", 998)
	elif mostro_overfitting_interactions == 0:
		NpcManager.play_dialog("mostro_overfitting", 0)
		mostro_overfitting_interactions += 1
		current_progression = Progression.TALKED_WITH_MOSTRO_OVERFITTING
		
		if not quest_given_mostro_overfitting:
			_create_quest(
				"talk_with_mostro_overfitting",
				"Parla con il Mostro Overfitting",
				"Il Mostro Overfitting minaccia il tuo modello! Impara come evitare l'overfitting."
			)
			quest_given_mostro_overfitting = true
			EventBus.quest_completed.emit("talk_with_mostro_overfitting")
			
	elif mostro_overfitting_interactions == 1:
		NpcManager.play_dialog("mostro_overfitting", 1)
		mostro_overfitting_interactions += 1
		
		current_progression = Progression.ALL_COMPLETED
		EventBus.quest_completed.emit("talk_with_mostro_overfitting")
		
		_create_quest(
			"all_quests_completed",
			"Maestro del Machine Learning",
			"Hai completato tutte le lezioni! Ora sei pronto per addestrare il tuo modello.",
			true
		)
		
	else:
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
	_give_start_quest()

func _physics_process(_delta: float) -> void:
	check_pause_menu_pressed("esc")
