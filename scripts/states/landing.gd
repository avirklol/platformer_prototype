extends State

@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State

func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO
	enable_wall_slide_collision(false)

func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		if direction().x == 0:
			if crouch_toggle():
				%StateMachine.change_state(crouching_state)
			elif jumping():
				%StateMachine.change_state(jumping_state)
			else:
				%StateMachine.change_state(standing_state)
		else:
			if running():
				%StateMachine.change_state(running_state)
			elif crouch_toggle():
				%StateMachine.change_state(crouch_walking_state)
			elif jumping():
				%StateMachine.change_state(jumping_state)
			else:
				%StateMachine.change_state(walking_state)

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state
	return null
