extends State

@export var falling_state: State
@export var wall_jump_state: State

func enter() -> void:
    super()
    effects.play(animation_name)
    enable_wall_slide_collision(true)

func exit() -> void:
    enable_wall_slide_collision(false)
    effects.play('none')

func process_physics(delta: float) -> State:
    parent.velocity.y += gravity * delta
    parent.velocity.y *= 0.86

    parent.move_and_slide()

    if !player_blocked_by_wall(%WallBodyCheck, direction().x):
        return falling_state
    else:
        if jumping():
            return wall_jump_state

    return null
