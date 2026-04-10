extends Node

signal dialogue_requested(npc_name: String, text: String) #unused
signal accuracy_updated(value: float)
signal npc_interacted(npc_id: String)
signal language_changed()
signal new_quest(quest: Quest)
signal quest_completed(quest_id: String)
signal quests_updated()
