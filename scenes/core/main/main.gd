extends Node2D

@export var player: Player
@export var pause_menu: PauseMenu
@export var doc_epoch: Npc
@export var lady_rate: Npc

var filename = get_script().get_path()

enum Progression {
	START,
	TALKED_WITH_DOC_EPOCH,
	TALKED_WITH_LADY_RATE,
}

var current_progression = Progression.START

func _ready() -> void:
	EventBus.npc_interacted.connect(interact_with_npc)

func interact_with_npc(npc_id: String):
	match npc_id:
		"doc_epoch":
			interact_with_doc_epoch()
		"lady_rate":
			interact_with_lady_rate()

func interact_with_doc_epoch():
	match current_progression:
		Progression.START:
			current_progression = Progression.TALKED_WITH_DOC_EPOCH
			NpcManager.play_dialog("doc_epoch", 0)  # dialogo iniziale
		Progression.TALKED_WITH_LADY_RATE:
			NpcManager.play_dialog("doc_epoch", 1)  # dialogo dopo lady_rate
		Progression.TALKED_WITH_DOC_EPOCH:
			NpcManager.play_dialog("doc_epoch", 2)  # dialogo di ritorno (già parlato)
		_:
			NpcManager.play_dialog("doc_epoch", 999)  # dialogo di default/filler

func interact_with_lady_rate():
	match current_progression:
		Progression.TALKED_WITH_DOC_EPOCH:
			current_progression = Progression.TALKED_WITH_LADY_RATE
			NpcManager.play_dialog("lady_rate", 0)  # dialogo missione
		Progression.START:
			NpcManager.play_dialog("lady_rate", 998)  # "torna quando hai parlato con doc"
		_:
			NpcManager.play_dialog("lady_rate", 2)  # dialogo post-missione

func check_esc_pressed():
	if Input.is_action_just_pressed("esc"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu._hide()
				get_tree().paused = false
			else:
				pause_menu._show()
				get_tree().paused = true


func _physics_process(_delta: float) -> void:
	check_esc_pressed()
