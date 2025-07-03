extends State

@export var standing_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State


func enter() -> void:
	super()


func process_input(event: InputEvent) -> State:
	if direction().x == 0:
		return standing_state
	else:
		if running():
			return running_state
		if crouch_toggle():
			return crouch_walking_state
		if jumping() and !%JumpCheck.is_colliding():
			return jumping_state
		return null


func process_physics(delta: float) -> State:
	var movement = direction().x * %Stats.force.walk

	if direction().x > 0:
		movement = 1 * %Stats.force.walk
	else:
		movement = -1 * %Stats.force.walk

	parent.velocity.x = movement
	parent.velocity.y += gravity * delta

	flip_animations(movement < 0)
	flip_collision_shapes(movement < 0)

	parent.move_and_slide()

	if parent.current_ladder:
		if %LadderTopCheck.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

		if %LadderBottomCheck.is_colliding() and !%LadderTopCheck.is_colliding():
			if direction().y > 0:
				return ladder_climb_down_state

	if pushing_wall(%HeadCheck, direction().x) or pushing_wall(%WallBodyCheck, direction().x):
		return standing_state

	if !parent.is_on_floor():
		return falling_state

	return null
