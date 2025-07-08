extends Node
class_name Inventory

@export var items: Array[InventoryItem] = []
var default_position: Vector2 = Vector2(0, 0)

func _ready() -> void:
	self.visible = false
	default_position = self.position

func add_item(item: InventoryItem):
	items.append(item)

func remove_item(item: InventoryItem):
	items.erase(item)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		self.visible = !self.visible
		self.position = default_position

	if self.visible:
		if Input.is_action_pressed("move_left"):
			self.position.x -= 10
		if Input.is_action_pressed("move_right"):
			self.position.x += 10
		if Input.is_action_pressed("move_up"):
			self.position.y -= 10
		if Input.is_action_pressed("move_down"):
			self.position.y += 10
