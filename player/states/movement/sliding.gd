extends State

# TODO: Needs a ton of refinement.

@export var standing_state: State

var deceleration: float = 0.0

func enter() -> void:
	super()
	deceleration = abs(parent.velocity.x) / 2

func process_physics(delta: float) -> State:

	if parent.velocity.x > 0:
		parent.velocity.x = max(0, parent.velocity.x - deceleration * delta)
	else:
		parent.velocity.x = min(0, parent.velocity.x + deceleration * delta)

	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if parent.velocity.x == 0:
		return standing_state

	return null
