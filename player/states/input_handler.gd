extends Node


func direction() -> Vector2:
    return Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))


func jumping() -> bool:
    return Input.is_action_just_pressed("jump")


func crouch_toggle() -> bool:
    return Input.is_action_just_pressed("crouch")


func running() -> bool:
    return Input.is_action_pressed("run")
