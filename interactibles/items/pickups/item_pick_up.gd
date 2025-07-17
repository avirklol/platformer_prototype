extends RigidBody2D

@export var item: ItemData
@export var collision_shape_size: Vector2 = Vector2(16, 16)

@onready var rigid_collision_shape: CollisionShape2D = %RigidCollisionShape
@onready var area_collision_shape: CollisionShape2D = %AreaCollisionShape
@onready var pickup_area: Area2D = %PickUpArea
@onready var animations: AnimatedSprite2D = %ItemAnimation



func _ready() -> void:
	mass = item.weight
	rigid_collision_shape.shape.size = collision_shape_size
	area_collision_shape.shape.size = collision_shape_size + Vector2(1, 1)
	area_collision_shape.disabled = true

	if item.sprite_sheet:
		animations.sprite_frames = item.sprite_sheet
		animations.play("default")

	pickup_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("characters"):
		body.inventory.add_item(item)
		queue_free()


func _physics_process(delta: float) -> void:
	if linear_velocity.y > 0:
		z_index = 1

	if linear_velocity.y == 0:
		area_collision_shape.disabled = false
		set_collision_mask_value(2, true)


func pop_out() -> void:
	var x_impulse: Vector2 = Vector2(randf() * 200 - 150, -350)

	apply_impulse(x_impulse, Vector2.ZERO)
	set_collision_mask_value(2, false)
