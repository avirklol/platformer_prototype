extends State

@export_category("Exit States")
@export var walking_state: State
@export var standing_state: State
@export var jumping_state: State
@export var falling_state: State
@export var crouching_state: State
@export var stop_running_state: State
# @export var sliding_state: State

@onready var b_audio: Dictionary = sound_database.db['states']['running']

var run_direction_history: float = 0.0


func enter() -> void:
	super()
	enable_running_collision(true)


func exit() -> void:
	super()
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

	if direction().x != 0:
		if !body_audio.playing:
			if b_audio.has(parent.is_on):
				body_audio.volume_db = surfaces.get(parent.is_on, surfaces.get("default")).get("volume_db", -6)
				body_audio.pitch_scale = surfaces.get(parent.is_on, surfaces.get("default")).get("pitch_scale", 1)
				body_audio.stream = b_audio[parent.is_on].pick_random()
				body_audio.play()
			else:
				print('body_audio: FALSE')

		if direction().x > 0:
			movement = 1 * stats.force.run
			run_direction_history = 1.0
		else:
			movement = -1 * stats.force.run
			run_direction_history = -1.0

		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

		parent.velocity.x = movement

	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if pushing_wall(head_check, direction().x) or pushing_wall(run_check, direction().x):
		return stop_running_state

	if !parent.is_on_floor():
		return falling_state

	return null


func enable_running_collision(enable: bool) -> void:
	if enable:
		run_check.target_position.x = 48
		head_check.target_position.x = 48
	else:
		run_check.target_position.x = 11
		head_check.target_position.x = 11
