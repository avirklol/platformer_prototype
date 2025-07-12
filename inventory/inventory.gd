extends Node
class_name Inventory

@onready var inventory_items: Array = %GridContainer.get_children()


func _ready() -> void:
	self.visible = false


func add_item(added_item: ItemData):
	for slot in inventory_items:
		if slot.item == null:
			slot.item = added_item
			return
		else:
			if slot.item.name == added_item.name and slot.item.stackable:
				slot.item.amount += added_item.amount
				return
			else:
				pass
	print("Inventory is full")


func remove_item(removed_item: ItemData):
	for slot in inventory_items:
		if slot.item == removed_item:
			slot.update_slot(null)
			return


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		self.visible = !self.visible
		if self.visible:
			print("Inventory contains:")
			for slot in inventory_items:
				if slot.item:
					print(str(slot.item.amount) + " " + str(slot.item.name))
