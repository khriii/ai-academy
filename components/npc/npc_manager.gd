extends Node

signal interaction_triggered(npc_id: String)

var dialog_scene: PackedScene = preload("res://scenes/ui/dialogue/dialog.tscn")

var npc_states: Dictionary = {}

func _ready() -> void:
	interaction_triggered.connect(interacted)

func interacted(npc_id: String) -> void:
	play_dialog(npc_id)

func play_dialog(npc_id: String, force_stage: int = -1) -> void:
	if not npc_states.has(npc_id):
		npc_states[npc_id] = {
			"dialog_stage": 0,
			"is_interactable": true
		}
	
	if not npc_states[npc_id].get("is_interactable", true):
		return
	
	var current_stage: int
	var use_forced_stage: bool = force_stage >= 0
	
	if use_forced_stage:
		current_stage = force_stage
	else:
		current_stage = npc_states[npc_id].get("dialog_stage", 0)
	
	var d_instance = dialog_scene.instantiate()
	get_tree().current_scene.add_child(d_instance)
	
	if use_forced_stage:
		d_instance.dialogue_finished.connect(_on_dialogue_finished_forced.bind(npc_id))
	else:
		d_instance.dialogue_finished.connect(_on_dialogue_finished_normal.bind(npc_id))
	
	d_instance.load_dialog(npc_id, current_stage)
	d_instance.play_next_dialog()

func _on_dialogue_finished_normal(npc_id: String) -> void:
	if npc_states.has(npc_id):
		npc_states[npc_id]["dialog_stage"] += 1

func _on_dialogue_finished_forced(_npc_id: String) -> void:
	pass

func get_save_data() -> Dictionary:
	return npc_states

func load_save_data(data: Dictionary) -> void:
	npc_states.clear()
	for npc_id in data:
		var npc_data = data[npc_id]
		npc_states[npc_id] = {
			"dialog_stage": npc_data.get("dialog_stage", 0), 
			"is_interactable": npc_data.get("is_interactable", true)
		}
