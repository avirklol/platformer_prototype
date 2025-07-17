extends State

@export_category("Exit States")
@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouch_walking_state: State
@export var ledge_grab_state: State
@export var landing_state: State
@export var wall_slide_state: State
@export var ladder_climb_state: State
@export var death_state: State

var high_fall: bool = false
var death: bool = false
# var initial_velocity: Vector2 = Vector2.ZERO #TODO: Implement velocity carryover from grounded movement.


func enter() -> void:
	super()

	camera.position_smoothing_speed = 50.0

	high_fall = false
	death = false

	if !against_wall_check.is_colliding():
		ledge_grab.disabled = false

	# initial_velocity = parent.velocity #TODO: Implement velocity carryover from grounded movement.


func exit() -> void:
	super()

	if state_machine.next_state != ledge_grab_state:
		ledge_grab.disabled = true


func process_input(event: InputEvent) -> State:
	if parent.current_ladder:
		if ladder_bottom_check.is_colliding() and ladder_top_check.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

	return null


func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.walk

	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

		parent.velocity.x = movement

	parent.velocity.y += gravity * delta

	if parent.velocity.y > stats.high_fall_velocity:
		high_fall = true

	if parent.velocity.y > stats.max_fall_velocity:
		death = true

	parent.move_and_slide()

	if parent.is_on_floor():
		if wall_body_check.is_colliding() and !floor_check.is_colliding() and !top_check.is_colliding() and !against_wall_check.is_colliding():
				return ledge_grab_state
		else:
			if death:
				return death_state
			if high_fall:
				return landing_state
			if direction().x != 0:
				if running():
					return running_state
				if crouch_toggle():
					return crouch_walking_state
				return walking_state
			return standing_state
	else:
		if wall_slide_check.is_colliding() and pushing_wall(wall_body_check, direction().x) and !floor_check.is_colliding():
			return wall_slide_state

	return null
