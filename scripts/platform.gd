extends AnimatableBody2D

@onready var pressure_plate = $PressurePlate
@onready var animation_player = get_node("%AnimationPlayer")


func _ready() -> void:
    pressure_plate.body_entered.connect(_onbody_entered)
    pressure_plate.body_exited.connect(_onbody_exited)


func _onbody_entered(body: Node2D) -> void:
    if body.is_in_group("Player"):
        animation_player.play("move_up")

func _onbody_exited(body: Node2D) -> void:
    if body.is_in_group("Player"):
        animation_player.play("move_down")
