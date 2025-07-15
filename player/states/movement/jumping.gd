extends State

@export var falling_state: State
@export var ledge_grab_state: State
@export var standing_state: State
@export var ladder_climb_state: State

# var initial_velocity: Vector2 = Vector2.ZERO #TODO: Implement velocity carryover from grounded movement.
@onready var jumping_audio: Array = sound_database.db['states']['jumping']['metal']
@onready var character_audio: Array = sound_database.db['voice']['jumping']


func enter() -> void:
	super()
	parent.velocity.y = -stats.force.jump
	if !voice_audio.playing and randi() % 3 == 0:
		voice_audio.stream = character_audio.pick_random()
		voice_audio.play()
	if !body_audio.playing:
		body_audio.volume_db = 2.0
		body_audio.pitch_scale = 1.0
		body_audio.stream = jumping_audio.pick_random()
		body_audio.play()
	# initial_velocity = parent.velocity #TODO: Implement velocity carryover from grounded movement.


func exit() -> void:
	super()

func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.walk

	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

	parent.velocity.y += gravity * delta
	parent.velocity.x = movement

	parent.move_and_slide()

	if parent.current_ladder:
		if %LadderBottomCheck.is_colliding() and %LadderTopCheck.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

	if parent.velocity.y > 0:
		return falling_state

	if parent.is_on_floor():
		return standing_state

	if %WallBodyCheck.is_colliding() and !%FloorCheck.is_colliding() and !%TopCheck.is_colliding() and parent.is_on_floor():
			return ledge_grab_state

	return null
