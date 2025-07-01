extends State

@export var falling_state: State
@export var ledge_grab_state: State
@export var standing_state: State
@export var ladder_climb_state: State
@export var jump_force: float = 300

# var initial_velocity: Vector2 = Vector2.ZERO #TODO: Implement velocity carryover from grounded movement.


func enter() -> void:
	super()
	parent.velocity.y = -jump_force
	# initial_velocity = parent.velocity #TODO: Implement velocity carryover from grounded movement.


func process_physics(delta: float) -> State:
	var movement = direction().x * move_speed

	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

	parent.velocity.y += gravity * delta
	parent.velocity.x = movement

	parent.move_and_slide()

	if parent.is_on_ladder and %LadderBottomCheck.is_colliding() and direction().y < 0:
		return ladder_climb_state

	if parent.velocity.y > 0:
		return falling_state

	if parent.is_on_floor():
		return standing_state

	if %WallBodyCheck.is_colliding() and !%FloorCheck.is_colliding() and !%TopCheck.is_colliding() and parent.is_on_floor():
			return ledge_grab_state

	return null
