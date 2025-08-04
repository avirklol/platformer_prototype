extends PanelContainer
class_name InteractionMenu

@onready var container: MarginContainer = %MarginContainer
@onready var background: NinePatchRect = %Background

@onready var item_interaction_menu: PackedScene = preload("res://menus/item_interaction.tscn")
@onready var interaction_button: PackedScene = preload("res://menus/interaction_button.tscn")
@onready var dialogue_interaction_menu: PackedScene = preload("res://menus/interaction_dialogue.tscn")

var target_object: Node = null

var buttons: Array[Button] = []
var dialogue_box: Label:
	set(value):
		dialogue_box = value

enum Type {
	ITEM,
	CONTAINER,
	CONSOLE,
	DEVICE,
	NPC
}


func create_interaction_menu(interaction_type: Type, num_buttons: int, button_names: PackedStringArray) -> void:
	match interaction_type:
		Type.ITEM:
			container.add_child(item_interaction_menu.instantiate())
			for i in range(num_buttons):
				var button = interaction_button.instantiate()
				button.text = button_names[i]
				buttons.append(button)
				container.get_node("ItemInteractionContainer").add_child(button)
		Type.NPC:
			container.add_child(dialogue_interaction_menu.instantiate())
			dialogue_box = container.get_node("DialogueBox")
		# InteractionType.CONTAINER:
		# 	container.add_child(container_interaction_menu.instantiate())
		# InteractionType.CONSOLE:
		# 	container.add_child(console_interaction_menu.instantiate())
		# InteractionType.NPC:
		# 	container.add_child(npc_interaction_menu.instantiate())


func _process(delta: float) -> void:
	if dialogue_box:
		if target_object.response_message != "":
			dialogue_box.text = target_object.response_message
		else:
			dialogue_box.text = "..."


func destroy_interaction_menu() -> void:
	for children in container.get_children():
		children.queue_free()
