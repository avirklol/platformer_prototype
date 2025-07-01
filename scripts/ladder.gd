extends Area2D

func _ready() -> void:
    add_to_group("ladder")
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("character"):
        body.is_on_ladder = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("character"):
        body.is_on_ladder = false
