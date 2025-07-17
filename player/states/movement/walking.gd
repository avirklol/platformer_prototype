extends State

@export_category("Exit States")
@export var standing_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State

@onready var b_audio: Dictionary = sound_database.db['states']['walking']


func enter() -> void:
	super()


func exit() -> void:
	super()


func process_input(event: InputEvent) -> State:
	if direction() == Vector2.ZERO:
		return standing_state
	else:
		if running():
			return running_state

		if crouch_toggle():
			return crouch_walking_state

		if jumping() and !jump_check.is_colliding():
			return jumping_state

		if parent.current_ladder:
			if ladder_top_check.is_colliding():
				if direction().y < 0:
					return ladder_climb_state

			if ladder_bottom_check.is_colliding() and !ladder_top_check.is_colliding():
				if direction().y > 0:
					return ladder_climb_down_state

		if pushing_wall(head_check, direction().x) or pushing_wall(wall_body_check, direction().x):
			return standing_state

		return null


func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.walk

	if movement:
		if !body_audio.playing:
			if b_audio.has(parent.is_on):
				body_audio.volume_db = surfaces.get(parent.is_on, surfaces.get("default")).get("volume_db", -10.0)
				body_audio.pitch_scale = surfaces.get(parent.is_on, surfaces.get("default")).get("pitch_scale", 1.2)
				body_audio.stream = b_audio[parent.is_on].pick_random()
				body_audio.play()
			else:
				print('body_audio: FALSE')

			if direction().x > 0:
				movement = 1 * stats.force.walk
			else:
				movement = -1 * stats.force.walk

			flip_animations(movement < 0)
			flip_collision_shapes(movement < 0)

			parent.velocity.x = movement

		parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null
