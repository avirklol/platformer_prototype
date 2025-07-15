extends State
# TODO: Verify if all these states are required.
@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State

@onready var landing_audio: Array = sound_database.db['states']['landing']['metal']
@onready var character_audio: Array = sound_database.db['voice']['landing']


func enter() -> void:
	super()
	parent.velocity = Vector2.ZERO
	if !voice_audio.playing:
		voice_audio.stream = character_audio.pick_random()
		voice_audio.play()
	if !body_audio.playing:
		body_audio.volume_db = -10.0
		body_audio.pitch_scale = 1.0
		body_audio.stream = landing_audio.pick_random()
		print('Playing landing audio!')
		print(landing_audio)
		body_audio.play()

func exit() -> void:
	super()


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		if direction().x == 0:
			if crouch_toggle():
				%StateMachine.change_state(crouching_state)
			elif jumping():
				%StateMachine.change_state(jumping_state)
			else:
				%StateMachine.change_state(standing_state)
		else:
			if running():
				%StateMachine.change_state(running_state)
			elif crouch_toggle():
				%StateMachine.change_state(crouch_walking_state)
			elif jumping():
				%StateMachine.change_state(jumping_state)
			else:
				%StateMachine.change_state(walking_state)


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null
