extends Panel

@onready var background: TextureRect = %SlotBackground
@onready var item_image: TextureRect = %ItemImage
@onready var item_count: Label = %StackCount

var active_slot: Texture2D = preload("res://assets/used/ui/Grid/Black/GridSlotC.png")
var inactive_slot: Texture2D = preload("res://assets/used/ui/Grid/Black/GridSlotInactive.png")
var item: ItemData = null


func _process(delta: float) -> void:
	update_slot(item)


func update_slot(current_item: ItemData):
	if !current_item:
		item_image.visible = false
		background.texture = inactive_slot
	else:
		item_image.visible = true
		item_image.texture = current_item.icon
		item_count.text = str(current_item.amount)
		background.texture = active_slot
