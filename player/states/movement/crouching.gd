extends State

@export var standing_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State
@export var ladder_climb_state: State
@export var ladder_climb_down_state: State


func enter() -> void:
	super()
	enable_crouch_collision(true)

	parent.velocity = Vector2.ZERO


func exit() -> void:
	if state_machine.next_state == crouch_walking_state or state_machine.next_state == null:
		enable_crouch_collision(true)
	else:
		enable_crouch_collision(false)


func process_input(event: InputEvent) -> State:
	if direction().x != 0 and !pushing_wall(crouch_wall_body_check, direction().x):
		return crouch_walking_state

	if !top_check.is_colliding():
		if jumping():
			return jumping_state
		if crouch_toggle():
			return standing_state

	if parent.current_ladder:
		if ladder_top_check.is_colliding():
			if direction().y < 0:
				return ladder_climb_state
		if ladder_bottom_check.is_colliding() and !ladder_top_check.is_colliding():
			if direction().y > 0:
				return ladder_climb_down_state

	return null


func process_physics(delta: float) -> State:
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
