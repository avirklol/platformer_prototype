extends Area2D

@export var item_type: String
@export var item_name: String
@export var item_rarity: int
@export var loot_amount: int = 1

@onready var animations: AnimatedSprite2D = %AnimatedSprite2D
# @onready var endless_timer: Timer = %EndlessTimer
@onready var item_pickup: PackedScene = preload("res://interactables/items/pickups/item_pick_up.tscn")


var player_in_range: bool = false
var opened: bool = false


func _ready() -> void:
	animations.play("closed")
	animations.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# endless_timer.timeout.connect(_on_timeout)


# func _on_timeout() -> void:
	# spawn_loot()
	# endless_timer.start()


func _on_animation_finished() -> void:
	if animations.name == "open" or animations.name == "open_empty":
		animations.play("opened")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("characters"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("characters"):
		player_in_range = false


func _process(delta: float) -> void:
	if player_in_range and !opened:
		if Input.is_action_just_pressed("interact"):
			animations.play("open")
			opened = true
			spawn_loot()
			# endless_timer.start()


func spawn_loot() -> void:
	for i in range(loot_amount):
		var item: ItemData = item_database.get_item(item_type, item_name, item_rarity)
		if item:
			var loot: Node2D = item_pickup.instantiate()
			loot.item = item.duplicate(true)
			loot.position = position
			loot.z_index = 0
			get_tree().current_scene.add_child(loot)
			loot.pop_out()
