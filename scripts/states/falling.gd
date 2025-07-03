extends State

@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
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
	%Camera2D.position_smoothing_speed = 50.0
	high_fall = false
	death = false
	if !%AgainstWallCheck.is_colliding():
		%LedgeGrab.disabled = false
	# initial_velocity = parent.velocity #TODO: Implement velocity carryover from grounded movement.


func exit() -> void:
	if %StateMachine.next_state != ledge_grab_state:
		%LedgeGrab.disabled = true

func process_physics(delta: float) -> State:
	var movement = direction().x * %Stats.force.walk

	parent.velocity.y += gravity * delta
	parent.velocity.x = movement
	print(parent.velocity.y)

	if parent.velocity.y > %Stats.high_fall_velocity:
		high_fall = true

	if parent.velocity.y > %Stats.max_fall_velocity:
		death = true

	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

	parent.move_and_slide()

	if parent.current_ladder:
		if %LadderBottomCheck.is_colliding() and %LadderTopCheck.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

	if parent.is_on_floor():
		if %WallBodyCheck.is_colliding() and !%FloorCheck.is_colliding() and !%TopCheck.is_colliding() and !%AgainstWallCheck.is_colliding():
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
					return crouching_state
				return walking_state
			return standing_state
	else:
		if %WallSlideCheck.is_colliding() and pushing_wall(%WallBodyCheck, direction().x) and !%FloorCheck.is_colliding():
			return wall_slide_state
		return null
