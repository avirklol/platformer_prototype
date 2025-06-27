extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const MIN_LANDING_VELOCITY = 350.0

@onready var animations = $PlayerAnimations
@onready var effects = $PlayerAnimations/Effects
@onready var state_debug = $StateDebug
@onready var onfloor_debug = $OnFloorDebug

enum states {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING,
	FALLING,
	LEDGE_GRAB,
	HANGING,
	CLIMBING,
	CROUCHING,
	CROUCH_WALKING,
	LANDING,
	WALL_SLIDE
}

const state_names := [
	"IDLE",
	"WALKING",
	"RUNNING",
	"JUMPING",
	"FALLING",
	"LEDGE_GRAB",
	"HANGING",
	"CLIMBING",
	"CROUCHING",
	"CROUCH_WALKING",
	"LANDING",
	"WALL_SLIDE"
]

var state = states.IDLE
var previous_states = [states.IDLE]
var velocity_y_history = [0.0]
var landing_engaged = false
var crouch_toggled = false
var wall_slide_toggled = false

func _ready():
	add_to_group("Player")
	animations.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
		if animations.animation == "ledge_climb":
			state = states.IDLE
			position.x += 14 if $LedgeCheck.get_collision_normal(0)[0] < 0 else -14
			position.y -= 40
			animations.play("idle")

		if animations.animation == "ledge_grab":
			state = states.HANGING

		if animations.animation == "landing":
			state = states.IDLE
			landing_engaged = false

func _on_ledge_release_timeout() -> void:
	disable_ledge_grab(false)

func _physics_process(delta: float) -> void:
	var input = Input

	# Apply gravity
	if !is_on_floor():
		velocity += get_gravity() * delta

	# Handle state transitions
	update_state()

	# Handle movement and animations
	handle_movement(input)
	update_animation()

	# Move the character
	move_and_slide()

	# Update debug information
	update_debug_info(input)

func update_state() -> void:
	previous_states.append(state)
	if len(previous_states) > 50:
		previous_states.pop_front()

	velocity_y_history.append(velocity.y)
	if len(velocity_y_history) > 50:
		velocity_y_history.pop_front()

	# Handle ledge grab first as it's a special case
	if state in [states.JUMPING, states.FALLING, states.WALL_SLIDE] and $LedgeCheck.is_colliding() and !$FloorCheck.is_colliding() and !$TopCheck.is_colliding() and is_on_floor():
		state = states.LEDGE_GRAB
		velocity.y = 0
		return

	# Handle floor-based states
	if is_on_floor():
		if states.FALLING in previous_states.slice(-5) and state not in [states.LEDGE_GRAB, states.HANGING, states.CLIMBING]:
			var max_fall_velocity = velocity_y_history.slice(-5).max()

			if max_fall_velocity > MIN_LANDING_VELOCITY:
				landing_engaged = true
				state = states.LANDING
			elif !landing_engaged:
				state = states.IDLE
	else:
		# Handle air states
		if $WallSlideCheck.is_colliding() and !$LedgeCheck.is_colliding() and $WallBodyCheck.is_colliding() and velocity.y > 0:
			state = states.WALL_SLIDE
			velocity.x *= 0.86
			velocity.y *= 0.86
			wall_slide_toggled = true
			return
		else:
			wall_slide_toggled = false

		if velocity.y < 0:
			state = states.JUMPING
		elif velocity.y > 0:
			crouch_toggled = false
			state = states.FALLING

	# Handle ledge grab exit conditions
	if state == states.LEDGE_GRAB:
		if $FloorCheck.is_colliding():
			state = states.IDLE
		elif !$LedgeCheck.is_colliding():
			state = states.FALLING
		if $TopCheck.is_colliding():
			velocity.y = 80

	if crouch_toggled:
		if state not in [states.JUMPING, states.FALLING]:
			state = states.CROUCHING

func update_animation() -> void:
	match state:
		states.IDLE:
			animations.play("idle")
			effects.play("none")
		states.WALKING:
			animations.play("walking")
			effects.play("none")
		states.RUNNING:
			animations.play("running")
		states.JUMPING:
			animations.play("jump_0")
			effects.play("none")
		states.LEDGE_GRAB:
			animations.play("ledge_grab")
			effects.play("none")
		states.FALLING:
			animations.play("jump_2")
			effects.play("none")
		states.HANGING:
			animations.play("ledge_hang")
		states.CLIMBING:
			animations.play("ledge_climb")
		states.CROUCHING:
			animations.play("crouch")
		states.CROUCH_WALKING:
			animations.play("crouch_walk")
		states.LANDING:
			animations.play("landing")
		states.WALL_SLIDE:
			animations.play("wall_slide")
			effects.play("wall_slide")

func handle_movement(input) -> void:
	var input_axis = [input.get_axis("move_left", "move_right"), input.get_axis("move_up", "move_down")]
	var is_running = input.is_action_pressed("run") and state not in [states.LEDGE_GRAB, states.HANGING, states.CLIMBING]
	var is_jumping = input.is_action_just_pressed("jump") and is_on_floor() and state not in [states.HANGING, states.CLIMBING, states.LEDGE_GRAB, states.LANDING]
	var is_climbing = (input.is_action_pressed("jump") or input_axis[1] < 0) and state in [states.HANGING]

	if input.is_action_just_pressed("crouch") and is_on_floor() and state not in [states.LEDGE_GRAB, states.HANGING, states.CLIMBING, states.RUNNING, states.LANDING] and !$TopCheck.is_colliding():
		crouch_toggled = !crouch_toggled

	if is_jumping:
		crouch_toggled = false

	if wall_slide_toggled:
		disable_non_wall_slide_collision(true)
	elif crouch_toggled:
		disable_non_crouch_collision(true)
	else:
		disable_non_crouch_collision(false)
		disable_non_wall_slide_collision(false)

	# Handle horizontal movement
	if input_axis[0] != 0 and state not in [states.LEDGE_GRAB, states.CLIMBING, states.LANDING]:
		# Update movement state
		if is_on_floor():
			if state in [states.HANGING]:
				if input_axis[0] > 0:
					if $LedgeCheck.get_collision_normal(0)[0] < 0:
						is_climbing = true
					else:
						pass
				else:
					if $LedgeCheck.get_collision_normal(0)[0] > 0:
						is_climbing = true
					else:
						pass
			else:
				if $WallBodyCheck.is_colliding():
					player_blocked_by_wall($WallBodyCheck, input_axis)
				elif $WallSlideCheck.is_colliding():
					player_blocked_by_wall($WallSlideCheck, input_axis)
				elif $CrouchWallBodyCheck.is_colliding():
					player_blocked_by_wall($CrouchWallBodyCheck, input_axis)
				else:
					if crouch_toggled:
						state = states.CROUCH_WALKING
					elif is_running:
						state = states.RUNNING
					else:
						state = states.WALKING

		# Handle sprite flipping
		var new_flip = input_axis[0] < 0
		if animations.flip_h != new_flip:
			animations.flip_h = new_flip
			effects.flip_h = new_flip
			flip_collision_shapes(new_flip)

		var speed_multiplier = 1

		if state in [states.CROUCHING, states.CROUCH_WALKING]:
			speed_multiplier = 0.5
		elif state in [states.FALLING, states.JUMPING]:
			speed_multiplier = 2 if states.RUNNING in previous_states else 1
		else:
			speed_multiplier = 2 if is_running else 1

		# Apply movement
		velocity.x = move_toward(velocity.x, input_axis[0] * SPEED * speed_multiplier, SPEED * speed_multiplier)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and state not in [states.LEDGE_GRAB, states.HANGING, states.CLIMBING, states.LANDING] and !crouch_toggled:
			state = states.IDLE

	if input_axis[1] > 0 and state in [states.HANGING]:
		disable_ledge_grab(true)
		position.x += 4 if $LedgeCheck.get_collision_normal(0)[0] >  0 else -4
	# Handle jumping
	if is_jumping:
		velocity.y = JUMP_VELOCITY
		state = states.JUMPING

	if is_climbing:
		state = states.CLIMBING

# COLLISION FUNCTIONS

func player_blocked_by_wall(shapecast, input_axis) -> void:
	if shapecast.get_collision_normal(0)[0] < 0 and input_axis[0] > 0:
		velocity.x = 0
		if crouch_toggled:
			state = states.CROUCHING
		else:
			state = states.IDLE

	elif shapecast.get_collision_normal(0)[0] > 0 and input_axis[0] < 0:
		velocity.x = 0
		if crouch_toggled:
			state = states.CROUCHING
		else:
			state = states.IDLE


func flip_collision_shapes(flip: bool) -> void:
	# Flip Collision Shapes
	var ledge_grab_pos = $LedgeGrab.position
	var wall_slide_pos = $WallSlideCollision.position
	ledge_grab_pos.x = -ledge_grab_pos.x if flip else abs(ledge_grab_pos.x)
	wall_slide_pos.x = -wall_slide_pos.x if flip else abs(wall_slide_pos.x)
	$LedgeGrab.position = ledge_grab_pos
	$WallSlideCollision.position = wall_slide_pos

	# Flip ShapeCasts
	var ledge_check_pos = $LedgeCheck.target_position
	ledge_check_pos.x = -ledge_check_pos.x if flip else abs(ledge_check_pos.x)
	$LedgeCheck.target_position = ledge_check_pos

func disable_ledge_grab(disable: bool, time: float = 0.5) -> void:
	if disable:
		$LedgeRelease.start(time)
		$LedgeGrab.disabled = true
		$LedgeCheck.enabled = false
		$FloorCheck.enabled = false
		$TopCheck.enabled = false
	else:
		$LedgeGrab.disabled = false
		$LedgeCheck.enabled = true
		$FloorCheck.enabled = true
		$TopCheck.enabled = true

func disable_non_crouch_collision(disable: bool) -> void:
	if disable:
		# Disabled
		$MainCollision.disabled = true
		$LedgeGrab.disabled = true
		$LedgeCheck.enabled = false
		$WallBodyCheck.enabled = false
		$WallSlideCollision.disabled = true
		$WallSlideCheck.enabled = false
		# Enabled
		$CrouchWallBodyCheck.enabled = true
		$CrouchCollision.disabled = false
	else:
		# Enabled
		$MainCollision.disabled = false
		$LedgeGrab.disabled = false
		$LedgeCheck.enabled = true
		$WallBodyCheck.enabled = true
		$WallSlideCheck.enabled = true
		$WallSlideCollision.disabled = true
		# Disabled
		$CrouchWallBodyCheck.enabled = false
		$CrouchCollision.disabled = true

func disable_non_wall_slide_collision(disable: bool) -> void:
	if disable:
		$MainCollision.disabled = true
		$LedgeGrab.disabled = true
		$LedgeCheck.enabled = false
		$WallSlideCollision.disabled = false

	else:
		$MainCollision.disabled = false
		$LedgeGrab.disabled = false
		$LedgeCheck.enabled = true
		$WallSlideCollision.disabled = true

# DEBUG FUNCTIONS

func get_direction(input) -> String:
	var input_axis = [input.get_axis("move_left", "move_right"), input.get_axis("move_up", "move_down")]

	if input_axis[0] > 0:
		return "right"
	elif input_axis[0] < 0:
		return "left"
	elif input_axis[1] > 0:
		return "down"
	elif input_axis[1] < 0:
		return "up"
	else:
		return "nothing"

func update_debug_info(input) -> void:
	state_debug.text = str(state_names[state])
	onfloor_debug.text = 'ON FLOOR:' + str(is_on_floor()).to_upper()
	print(
		str(state_names[state])
		+ ' --- ' + 'Velocity: ' + str(velocity)
		+ ' --- ' + 'Input Axis: ' + '[X] ' + str(input.get_axis("move_left", "move_right")) + ' [Y] ' + str(input.get_axis("move_up", "move_down")) + ' // ' + get_direction(input).to_upper() + ' PRESSED'
		+ ' --- ' + 'Ledge Check: ' + str($LedgeCheck.is_colliding()).to_upper()
		+ ' --- ' + 'Wall Check: ' + str($WallSlideCheck.is_colliding()).to_upper()
		+ ' --- ' + 'Floor Check: ' + str($FloorCheck.is_colliding()).to_upper()
		+ ' --- ' + 'Top Check: ' + str($TopCheck.is_colliding()).to_upper()
		+ ' --- ' + 'On Floor: ' + str(is_on_floor()).to_upper()
		+ ' --- ' + 'Ledge Collision Normal: ' + str($LedgeCheck.get_collision_normal(0) if $LedgeCheck.is_colliding() else 'N/A')
		+ ' --- ' + 'Wall Slide Collision Normal: ' + str($WallSlideCheck.get_collision_normal(0) if $WallSlideCheck.is_colliding() else 'N/A')
		+ ' --- ' + 'Wall Body Collision Normal: ' + str($WallBodyCheck.get_collision_normal(0) if $WallBodyCheck.is_colliding() else 'N/A')
		# + ' --- ' + 'Ledge Check Data: ' + str($LedgeCheck.collision_result  if $LedgeCheck.is_colliding() else 'N/A')
		# + ' --- ' + 'Previous States: ' + '[' + str(previous_states.map(func(state): return state_names[state])[0:5]) + ']'
		)
