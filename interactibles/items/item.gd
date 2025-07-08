extends Resource
class_name InventoryItem

@export var name: String
@export var description: String
@export var icon: Texture2D = null
@export var type: String
@export var amount: int = 0
@export var max_stack: int = 1
@export var stackable: bool = true
@export var unique: bool = false
