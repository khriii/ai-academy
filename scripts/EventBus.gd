# Da aggiungere come Autoload in Project > Project Settings > Autoload
extends Node

signal quest_completed(level_id: String)
signal dialogue_requested(npc_name: String, text: String)
signal accuracy_updated(value: float)
