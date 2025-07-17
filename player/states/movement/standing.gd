extends State

@export_category("Exit States")
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State

func enter() -> void:
	super()

	parent.velocity = Vector2.ZERO


func process_input(event: InputEvent) -> State:
	if direction().x != 0 and (!pushing_wall(head_check, direction().x) and !pushing_wall(wall_body_check, direction().x)):
		if running():
			return running_state
		return walking_state

	if crouch_toggle():
		return crouching_state

	if jumping() and !jump_check.is_colliding():
		return jumping_state

	if parent.current_ladder:
		if ladder_top_check.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

		if ladder_bottom_check.is_colliding() and !ladder_top_check.is_colliding():
			if direction().y > 0:
				return ladder_climb_down_state

	return null

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null
