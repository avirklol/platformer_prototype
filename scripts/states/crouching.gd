extends State

@export var standing_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State


func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO
	enable_crouch_collision(true)


func exit() -> void:
	if %StateMachine.next_state == crouch_walking_state or %StateMachine.next_state == null:
		enable_crouch_collision(true)
	else:
		enable_crouch_collision(false)


func process_input(event: InputEvent) -> State:
	if direction().x != 0 and !pushing_wall(%CrouchWallBodyCheck, direction().x):
		return crouch_walking_state

	if !%TopCheck.is_colliding():
		if jumping():
			return jumping_state
		if crouch_toggle():
			return standing_state

	return null


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()

	if parent.current_ladder:
		if %LadderTopCheck.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

		if %LadderBottomCheck.is_colliding() and !%LadderTopCheck.is_colliding():
			if direction().y > 0:
				return ladder_climb_down_state

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
