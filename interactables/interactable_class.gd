extends Area2D
class_name Interactable

@export var interaction_data: InteractionData

var player: CharacterBody2D = null
var interaction_active: bool = false
var interaction_menu: InteractionMenu = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("characters"):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("characters"):
		player = null

func open_interaction() -> void:
	pass


func close_interaction() -> void:
	interaction_menu.visible = false
	# interaction_menu.size = Vector2(0, 0)
	interaction_menu.destroy_interaction_menu()
	interaction_active = false
	interaction_menu = null
