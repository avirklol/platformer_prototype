extends Resource
class_name ItemData

enum ItemType {
	WEAPON,
	ARMOR,
	TOOL,
	CONSUMABLE,
    KEY,
	RESOURCE
}

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var name: String
@export var description: String
@export var icon: Texture2D = null
@export var sprite_sheet: SpriteFrames = null
@export var weight: float = 0.0
@export var value: int = 0
@export var rarity: ItemRarity
@export var type: ItemType
@export var amount: int = 0
@export var max_stack: int = 1
@export var stackable: bool = true
@export var unique: bool = false
