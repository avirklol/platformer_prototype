extends State

@export var jump_force: float = 300.0
@export var falling_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()
	parent.velocity.y = -jump_force
	parent.velocity.x = direction().x * jump_force * 0.5

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.velocity.x = direction().x * jump_force * 0.5
	parent.move_and_slide()

	if !player_blocked_by_wall(%WallBodyCheck, direction().x):
		return falling_state
	else:
		return wall_slide_state
