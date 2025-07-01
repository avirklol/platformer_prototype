extends State

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
	var movement = direction().x * move_speed
	parent.velocity.x = movement
	parent.velocity.y += gravity * delta
	parent.velocity.y *= 0.86

	parent.move_and_slide()

	if !pushing_wall(%WallBodyCheck, direction().x):
		return falling_state
	else:
		if jumping():
			return wall_jump_state
		elif %FloorCheck.is_colliding():
			return standing_state

	return null


func enable_wall_slide_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		# Disabled ShapeCasts
		%HeadCheck.enabled = false
		# Enabled CollisionShapes
		%WallSlideCollision.disabled = false

	else:
		# Enabled CollisionShapes
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		# Enabled ShapeCasts
		%HeadCheck.enabled = true
		# Disabled CollisionShapes
		%WallSlideCollision.disabled = true
