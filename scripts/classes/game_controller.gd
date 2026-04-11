class_name GameController
extends Node

@export var player: Player
@export var pause_menu: PauseMenu

var name_tag_scene: PackedScene = preload("res://scenes/ui/name_tag/name_tag.tscn")

var filename = get_script().get_path()

enum Progression {
	START,
	TALKED_WITH_DOC_EPOCH,
	TALKED_WITH_LADY_RATE,
	TALKED_WITH_MASTER_BIAS,
	TALKED_WITH_MOSTRO_OVERFITTING,
	ALL_COMPLETED,
}

var current_progression = Progression.START

var doc_epoch_interactions = 0
var lady_rate_interactions = 0
var master_bias_interactions = 0
var mostro_overfitting_interactions = 0

var quest_given_start = false
var quest_given_doc_epoch = false
var quest_given_lady_rate = false
var quest_given_master_bias = false
var quest_given_mostro_overfitting = false

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

func _give_start_quest():
	if not quest_given_start:
		QuestManager.add_quest("talk_with_doc_epoch", false)
		quest_given_start = true

func interact_with_doc_epoch():
	if doc_epoch_interactions == 0:
		NpcManager.play_dialog("doc_epoch", 0)
		doc_epoch_interactions += 1
		current_progression = Progression.TALKED_WITH_DOC_EPOCH
		
		if not quest_given_doc_epoch:
			quest_given_doc_epoch = true
			QuestManager.complete_quest("talk_with_doc_epoch")
			
	elif doc_epoch_interactions == 1:
		NpcManager.play_dialog("doc_epoch", 1)
		doc_epoch_interactions += 1
		QuestManager.add_quest("talk_with_lady_rate", false)
		
	elif doc_epoch_interactions == 2:
		if mostro_overfitting_interactions >= 2:
			NpcManager.play_dialog("doc_epoch", 2)
			doc_epoch_interactions += 1
			QuestManager.add_quest("all_quests_completed", true)
		else:
			NpcManager.play_dialog("doc_epoch", 998)
			
	else:
		NpcManager.play_dialog("doc_epoch", 997)

func interact_with_lady_rate():
	if doc_epoch_interactions < 2:
		NpcManager.play_dialog("lady_rate", 998)
	elif lady_rate_interactions == 0:
		NpcManager.play_dialog("lady_rate", 0)
		lady_rate_interactions += 1
		current_progression = Progression.TALKED_WITH_LADY_RATE
		
		if not quest_given_lady_rate:
			quest_given_lady_rate = true
			QuestManager.complete_quest("talk_with_lady_rate")
			
	elif lady_rate_interactions == 1:
		NpcManager.play_dialog("lady_rate", 1)
		lady_rate_interactions += 1
		QuestManager.add_quest("talk_with_master_bias", false)
		
	else:
		NpcManager.play_dialog("lady_rate", 997)

func interact_with_master_bias():
	if lady_rate_interactions < 2:
		NpcManager.play_dialog("master_bias", 998)
	elif master_bias_interactions == 0:
		NpcManager.play_dialog("master_bias", 0)
		master_bias_interactions += 1
		current_progression = Progression.TALKED_WITH_MASTER_BIAS
		
		if not quest_given_master_bias:
			quest_given_master_bias = true
			QuestManager.complete_quest("talk_with_master_bias")
			
	elif master_bias_interactions == 1:
		NpcManager.play_dialog("master_bias", 1)
		master_bias_interactions += 1
		QuestManager.add_quest("talk_with_mostro_overfitting", false)
		
	else:
		NpcManager.play_dialog("master_bias", 997)

func interact_with_mostro_overfitting():
	if master_bias_interactions < 2:
		NpcManager.play_dialog("mostro_overfitting", 998)
	elif mostro_overfitting_interactions == 0:
		NpcManager.play_dialog("mostro_overfitting", 0)
		mostro_overfitting_interactions += 1
		current_progression = Progression.TALKED_WITH_MOSTRO_OVERFITTING
		
		if not quest_given_mostro_overfitting:
			quest_given_mostro_overfitting = true
			QuestManager.complete_quest("talk_with_mostro_overfitting")
			
	elif mostro_overfitting_interactions == 1:
		NpcManager.play_dialog("mostro_overfitting", 1)
		mostro_overfitting_interactions += 1
		current_progression = Progression.ALL_COMPLETED
		
	else:
		NpcManager.play_dialog("mostro_overfitting", 997)

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
	add_nametags()

func _physics_process(_delta: float) -> void:
	check_pause_menu_pressed("esc")

func add_nametags():
	var children = get_parent().get_children()
	
	for c in children:
		if c is Npc and name_tag_scene:
			var name_tag = name_tag_scene.instantiate()
			name_tag.set_tag(c._name)
			c.add_child(name_tag)
			name_tag.global_position = Vector2(c.global_position.x, c.global_position.y - 18)
