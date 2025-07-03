extends State

@export var jump_force: float = 150.0
@export var falling_state: State
@export var wall_slide_state: State


func enter() -> void:
	super()
	parent.velocity.y = -jump_force * 3
	if %WallBodyCheck.get_collision_normal(0)[0] < 0:
		parent.velocity.x = -jump_force
		flip_animations(true)
		flip_collision_shapes(true)
	else:
		parent.velocity.x = jump_force
		flip_animations(false)
		flip_collision_shapes(false)


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		var movement = direction().x * walk_speed
		parent.velocity.x = movement
		if !pushing_wall(%WallSlideCheck, direction().x):
			%StateMachine.change_state(falling_state)
		else:
			%StateMachine.change_state(wall_slide_state)


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	return null
