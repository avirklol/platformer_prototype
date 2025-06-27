extends State

@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var falling_state: State
@export var jumping_state: State

func enter() -> void:
	super()
	enable_wall_slide_collision(false)

func exit() -> void:
	parent.position.x += 14 if %WallBodyCheck.get_collision_normal(0)[0] < 0 else -14
	parent.position.y -= 40

func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		%StateMachine.change_state(standing_state)
