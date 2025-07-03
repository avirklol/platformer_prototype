extends State

@export var walking_state: State
@export var standing_state: State
@export var jumping_state: State
@export var falling_state: State
@export var crouching_state: State
@export var stop_running_state: State
# @export var sliding_state: State

var run_direction_history: float = 0.0


func enter() -> void:
	super()
	enable_running_collision(true)


func exit() -> void:
	enable_running_collision(false)
	flip_animations(run_direction_history < 0)
	flip_collision_shapes(run_direction_history < 0)


func process_input(event: InputEvent) -> State:
	if direction().x == 0:
		return stop_running_state
	else:
		if !running():
			return stop_running_state
		if crouch_toggle():
			return stop_running_state
		if jumping():
			return jumping_state
		return null


func process_physics(delta: float) -> State:
	var movement = 0

	if direction().x > 0:
		movement = 1 * run_speed
		run_direction_history = 1.0
	else:
		movement = -1 * run_speed
		run_direction_history = -1.0

	parent.velocity.x = movement
	parent.velocity.y += gravity * delta

	flip_animations(movement < 0)
	flip_collision_shapes(movement < 0)

	parent.move_and_slide()

	if pushing_wall(%HeadCheck, direction().x) or pushing_wall(%RunCheck, direction().x):
		return stop_running_state

	if !parent.is_on_floor():
		return falling_state

	return null


func enable_running_collision(enable: bool) -> void:
	if enable:
		%RunCheck.target_position.x = 48
		%HeadCheck.target_position.x = 48
	else:
		%RunCheck.target_position.x = 11
		%HeadCheck.target_position.x = 11
