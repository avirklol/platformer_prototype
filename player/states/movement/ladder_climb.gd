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
	if state_machine.next_state != ladder_top_state:
		if in_collision:
			enable_ladder_collision(false)
			disable_main_collision(true)
			in_collision = false
		else:
			enable_ladder_collision(false)


func process_frame(delta: float) -> State:
	if direction().y < 0:
		animations.play(animation_name)
		return null
	elif direction().y > 0 and !parent.is_on_floor():
		animations.play_backwards(animation_name)
		return null
	else:
		animations.pause()
		return null


func process_input(event: InputEvent) -> State:
	if jumping():
		disable_ladder_shapes(true)

		if jump_check.is_colliding():
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
		movement_y = -stats.force.climb
	elif direction().y > 0:
		movement_y = stats.force.climb

	if movement_y != 0:
		parent.velocity.y = movement_y
	else:
		parent.velocity.y = 0

	parent.velocity.x = 0

	parent.move_and_slide()

	if parent.is_on_floor():
			return standing_state

	if !parent.current_ladder and !floor_check.is_colliding():
		return falling_state

	if ladder_top_check.is_colliding() and direction().y < 0:
		if ladder_top_check.get_collision_normal(0)[1] < 0:
			return ladder_top_state

	return null


func enable_ladder_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		main_collision.disabled = true
		ledge_grab.disabled = true
		# Disabled ShapeCasts
		wall_slide_check.enabled = false
		head_check.enabled = false
		wall_body_check.enabled = false
		# Enabled CollisionShapes
		ladder_collision.disabled = false
	else:
		# Enabled CollisionShapes
		main_collision.disabled = false
		ledge_grab.disabled = false
		# Enabled ShapeCasts
		wall_slide_check.enabled = true
		head_check.enabled = true
		wall_body_check.enabled = true
		# Disabled CollisionShapes
		ladder_collision.disabled = true


func center_player() -> void:
	var ladder = parent.current_ladder
	if ladder:
		var ladder_position = ladder.global_position
		# var ladder_size = ladder.get_node("CollisionShape2D").shape.size

		parent.global_position.x = ladder_position.x
