extends Interactable
class_name NPC

@export_group("RPG Stats")
@export var first_name: String
@export var last_name: String
@export var age: int
@export var gender: String
@export var country: String
@export var location: String
@export var occupation: String
@export var personality: String
@export var bio: String
@export var goals: String
@export var interests: String
@export var alignment: String
@export var is_merchant: bool = false
@export var is_hostile: bool = false

@export_group("AI")
@export var brain: AIBrain

@export_group("Gameplay Stats")
@export var height: float
@export var weight: float
@export var health: int = 100
@export var stamina: int = 100
@export var tech_points: int = 10
@export var attack: int = 10
@export var defense: int = 5
@export var level: int = 1
@export var experience: int = 0

@export_group("Inventory")
@export var inventory: Array[ItemData] = []
@export var randomize_loot: bool = false
@export var loot_type: String
@export var loot_name: String
@export var loot_rarity: int
@export var loot_quantity: int
@export var loot_chance: float
