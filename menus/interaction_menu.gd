extends PanelContainer
class_name InteractionMenu

@onready var container: MarginContainer = %MarginContainer
@onready var background: NinePatchRect = %Background

@onready var item_interaction_menu: PackedScene = preload("res://menus/item_interaction.tscn")
@onready var interaction_button: PackedScene = preload("res://menus/interaction_button.tscn")

enum Type {
	ITEM,
	CONTAINER,
	CONSOLE,
    DEVICE,
	NPC
}


func create_interaction_menu(interaction_type: Type, num_buttons: int, button_names) -> void:
	match interaction_type:
		Type.ITEM:
			container.add_child(item_interaction_menu.instantiate())
			for i in range(num_buttons):
				var button = interaction_button.instantiate()
				button.text = button_names[i]
				container.get_node("ItemInteractionContainer").add_child(button)
		# InteractionType.CONTAINER:
		# 	container.add_child(container_interaction_menu.instantiate())
		# InteractionType.CONSOLE:
		# 	container.add_child(console_interaction_menu.instantiate())
		# InteractionType.NPC:
		# 	container.add_child(npc_interaction_menu.instantiate())


func destroy_interaction_menu() -> void:
	container.get_node("ItemInteractionContainer").queue_free()
