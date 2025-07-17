extends State

@export_category("Exit States")
@export var falling_state: State
@export var wall_jump_state: State
@export var standing_state: State


func enter() -> void:
	super()
	effects.play(animation_name)
	enable_wall_slide_collision(true)


func exit() -> void:
	enable_wall_slide_collision(false)
	effects.play('none')


func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.walk
	parent.velocity.x = movement
	parent.velocity.y += gravity * delta
	parent.velocity.y *= 0.86

	parent.move_and_slide()

	if !pushing_wall(wall_body_check, direction().x):
		return falling_state
	else:
		if jumping():
			return wall_jump_state
		elif floor_check.is_colliding():
			return standing_state

	return null


func enable_wall_slide_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		main_collision.disabled = true
		ledge_grab.disabled = true
		# Disabled ShapeCasts
		head_check.enabled = false
		# Enabled CollisionShapes
		wall_slide_collision.disabled = false

	else:
		# Enabled CollisionShapes
		main_collision.disabled = false
		# Enabled ShapeCasts
		head_check.enabled = true
		# Disabled CollisionShapes
		wall_slide_collision.disabled = true
