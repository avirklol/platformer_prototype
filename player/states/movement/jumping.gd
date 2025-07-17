extends State

@export_category("Exit States")
@export var falling_state: State
@export var ledge_grab_state: State
@export var standing_state: State
@export var ladder_climb_state: State

# var initial_velocity: Vector2 = Vector2.ZERO #TODO: Implement velocity carryover from grounded movement.
@onready var b_audio: Dictionary = sound_database.db['states']['jumping']
@onready var v_audio: Array = sound_database.db['voice']['jumping']


func enter() -> void:
	super()

	parent.velocity.y = -stats.force.jump

	if !voice_audio.playing and randi() % 3 == 0:
		voice_audio.stream = v_audio.pick_random()
		voice_audio.play()

	if !body_audio.playing:
		if b_audio.has(parent.is_on):
			body_audio.volume_db = surfaces.get(parent.is_on, surfaces.get("default")).get("volume_db", 2.0)
			body_audio.pitch_scale = surfaces.get(parent.is_on, surfaces.get("default")).get("pitch_scale", 1.0)
			body_audio.stream = b_audio[parent.is_on].pick_random()
			body_audio.play()
		else:
			print('body_audio: FALSE')

	# initial_velocity = parent.velocity #TODO: Implement velocity carryover from grounded movement.


func exit() -> void:
	super()

func process_physics(delta: float) -> State:
	var movement = direction().x * stats.force.walk

	if movement != 0:
		flip_animations(movement < 0)
		flip_collision_shapes(movement < 0)

		parent.velocity.x = movement

	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if parent.current_ladder:
		if ladder_bottom_check.is_colliding() and ladder_top_check.is_colliding():
			if direction().y < 0:
				return ladder_climb_state

	if parent.velocity.y > 0:
		return falling_state

	if parent.is_on_floor():
		return standing_state

	return null
