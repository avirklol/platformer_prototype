extends Area2D

signal ladder_entered(ladder: Area2D)


func _ready() -> void:
    add_to_group("ladders")
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("characters"):
        body.current_ladder = self
        ladder_entered.emit(self)


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("characters"):
        body.current_ladder = null
