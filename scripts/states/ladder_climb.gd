extends State

@export var falling_state: State
@export var standing_state: State
@export var ladder_top_state: State
@export var jumping_state: State

var in_collision: bool = false


func enter() -> void:
	enable_ladder_collision(true)
	center_player()


func exit() -> void:
	if %StateMachine.next_state != ladder_top_state:
		if in_collision:
			enable_ladder_collision(false)
			disable_main_collision(true)
			in_collision = false
		else:
			enable_ladder_collision(false)


func process_frame(delta: float) -> State:
	if direction().y < 0:
		animations.play("ladder_climbing")
		return null
	elif direction().y > 0 and !parent.is_on_floor():
		animations.play_backwards("ladder_climbing")
		return null
	else:
		animations.pause()
		return null


func process_input(event: InputEvent) -> State:
	if jumping():
		disable_ladder_shapes(true)

		if %JumpCheck.is_colliding():
			in_collision = true
			return falling_state
		else:
			if direction().x != 0:
				return jumping_state

		return falling_state

	return null


func process_physics(delta: float) -> State:
	var movement_y = 0

	if direction().y < 0:
		movement_y = -climb_speed
	elif direction().y > 0:
		movement_y = climb_speed

	if movement_y != 0:
		parent.velocity.y = movement_y
	else:
		parent.velocity.y = 0

	parent.velocity.x = 0

	parent.move_and_slide()

	if parent.is_on_floor():
			return standing_state

	if !parent.current_ladder and !%FloorCheck.is_colliding():
		return falling_state

	if %LadderTopCheck.is_colliding() and direction().y < 0:
		if %LadderTopCheck.get_collision_normal(0)[1] < 0:
			return ladder_top_state

	return null


func enable_ladder_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		# Disabled ShapeCasts
		%WallSlideCheck.enabled = false
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
		# Enabled CollisionShapes
		%LadderCollision.disabled = false
	else:
		# Enabled CollisionShapes
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		# Enabled ShapeCasts
		%WallSlideCheck.enabled = true
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
		# Disabled CollisionShapes
		%LadderCollision.disabled = true


func center_player() -> void:
	var ladder = parent.current_ladder
	if ladder:
		var ladder_position = ladder.global_position
		# var ladder_size = ladder.get_node("CollisionShape2D").shape.size

		parent.global_position.x = ladder_position.x
