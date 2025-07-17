extends State

@export var falling_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()

	parent.velocity.y = -stats.force.jump * 1.5

	if wall_body_check.get_collision_normal(0)[0] < 0:
		parent.velocity.x = -stats.force.jump / 2
		flip_animations(true)
		flip_collision_shapes(true)
	else:
		parent.velocity.x = stats.force.jump / 2
		flip_animations(false)
		flip_collision_shapes(false)


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		var movement = direction().x * stats.force.walk

		parent.velocity.x = movement

		if !pushing_wall(wall_slide_check, direction().x):
			state_machine.change_state(falling_state)
		else:
			state_machine.change_state(wall_slide_state)


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	return null
