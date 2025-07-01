extends State

@export var crouching_state: State
@export var walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State


func enter() -> void:
	super()
	enable_crouch_collision(true)


func exit() -> void:
	if %StateMachine.next_state == crouching_state or %StateMachine.next_state == null:
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
		return null


func process_physics(delta: float) -> State:
	var movement = direction().x * move_speed
	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

	parent.velocity.x = movement
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if parent.current_ladder and direction().y < 0:
		return ladder_climb_state

	if pushing_wall(%CrouchWallBodyCheck, direction().x):
		return crouching_state

	if !parent.is_on_floor():
		return falling_state

	return null


func enable_crouch_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		# Disabled ShapeCasts
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
		%WallSlideCheck.enabled = false
		# Enabled CollisionShapes
		%CrouchCollision.disabled = false
		# Enabled ShapeCasts
		%CrouchWallBodyCheck.enabled = true
		# Resized Objects
		%TopCheck.shape.size.x = 17
	else:
		# Enabled CollisionShapes
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		# Enabled ShapeCasts
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
		%WallSlideCheck.enabled = true
		# Disabled CollisionShapes
		%CrouchCollision.disabled = true
		# Disabled ShapeCasts
		%CrouchWallBodyCheck.enabled = false
		# Resized Objects
		%TopCheck.shape.size.x = 20
