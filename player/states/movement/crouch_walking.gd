extends State

@export_category("Exit States")
@export var crouching_state: State
@export var walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State

@onready var b_audio: Dictionary = sound_database.db['states']['walking']


func enter() -> void:
	super()
	enable_crouch_collision(true)


func exit() -> void:
	super()

	if state_machine.next_state == crouching_state or state_machine.next_state == null:
		enable_crouch_collision(true)
	else:
		enable_crouch_collision(false)


func process_input(event: InputEvent) -> State:
	if direction().x == 0:
		return crouching_state
	else:
		if !%TopCheck.is_colliding():
			if jumping():
				return jumping_state
			if crouch_toggle():
				return walking_state
		if parent.current_ladder:
			if ladder_top_check.is_colliding():
				if direction().y < 0:
					return ladder_climb_state
			if ladder_bottom_check.is_colliding() and !ladder_top_check.is_colliding():
				if direction().y > 0:
					return ladder_climb_down_state
		if pushing_wall(crouch_wall_body_check, direction().x):
			return crouching_state
		return null

func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.crouch

	if movement:
		if !body_audio.playing:
			if b_audio.has(parent.is_on):
				body_audio.volume_db = surfaces.get(parent.is_on, surfaces.get("default")).get("volume_db", -10.0)
				body_audio.pitch_scale = surfaces.get(parent.is_on, surfaces.get("default")).get("pitch_scale", 1.2)
				body_audio.stream = b_audio[parent.is_on].pick_random()
				body_audio.play()
			else:
				print('body_audio: FALSE')

		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

		parent.velocity.x = movement

	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null


func enable_crouch_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		main_collision.disabled = true
		# Disabled ShapeCasts
		head_check.enabled = false
		wall_body_check.enabled = false
		wall_slide_check.enabled = false
		# Enabled CollisionShapes
		crouch_collision.disabled = false
		# Enabled ShapeCasts
		crouch_wall_body_check.enabled = true
	else:
		# Enabled CollisionShapes
		main_collision.disabled = false
		# Enabled ShapeCasts
		head_check.enabled = true
		wall_body_check.enabled = true
		wall_slide_check.enabled = true
		# Disabled CollisionShapes
		crouch_collision.disabled = true
		# Disabled ShapeCasts
		crouch_wall_body_check.enabled = false
