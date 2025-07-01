extends State

@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var falling_state: State
@export var jumping_state: State

@export var animation_fps: float = 8

var deceleration: float = 0.0


func enter() -> void:
	super()
	deceleration = abs(parent.velocity.x) / (animation_fps / animations.sprite_frames.get_frame_count(animation_name)) * 5


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
			if !pushing_wall(%HeadCheck, direction().x) and !pushing_wall(%WallBodyCheck, direction().x):
				%StateMachine.change_state(walking_state)
			else:
				if jumping():
					%StateMachine.change_state(jumping_state)
				%StateMachine.change_state(standing_state)


func process_physics(delta: float) -> State:
	if parent.velocity.x > 0:
		parent.velocity.x = max(0, parent.velocity.x - deceleration * delta)
	else:
		parent.velocity.x = min(0, parent.velocity.x + deceleration * delta)

	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null
