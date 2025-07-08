extends State

@export var falling_state: State
@export var ledge_climb_state: State


func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO


func process_physics(delta: float) -> State:
	if direction().y > 0:
		parent.position.x += -4 if %WallBodyCheck.get_collision_normal(0)[0] < 0 else 4
		return falling_state

	if direction().y < 0 or (direction().x == 0 and jumping()):
		return ledge_climb_state

	return null
