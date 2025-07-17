extends State

@export_category("Exit States")
@export var standing_state: State
@export var walking_state: State
@export var running_state: State
@export var crouching_state: State
@export var crouch_walking_state: State
@export var jumping_state: State
@export var falling_state: State

@onready var b_audio: Dictionary = sound_database.db['states']['landing']
@onready var v_audio: Array = sound_database.db['voice']['landing']


func enter() -> void:
	super()

	parent.velocity = Vector2.ZERO

	if !voice_audio.playing:
		voice_audio.stream = v_audio.pick_random()
		voice_audio.play()

	if !body_audio.playing:
		if b_audio.has(parent.is_on):
			body_audio.volume_db = surfaces.get(parent.is_on, surfaces.get("default")).get("volume_db", -10.0)
			body_audio.pitch_scale = surfaces.get(parent.is_on, surfaces.get("default")).get("pitch_scale", 1.0)
			body_audio.stream = b_audio[parent.is_on].pick_random()
			body_audio.play()
		else:
			print('body_audio: FALSE')

func exit() -> void:
	super()


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		if direction().x == 0:
			if crouch_toggle():
				state_machine.change_state(crouching_state)
			elif jumping():
				state_machine.change_state(jumping_state)
			else:
				state_machine.change_state(standing_state)
		else:
			if running():
				state_machine.change_state(running_state)
			elif crouch_toggle():
				state_machine.change_state(crouch_walking_state)
			elif jumping():
				state_machine.change_state(jumping_state)
			else:
				state_machine.change_state(walking_state)


func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	parent.move_and_slide()

	if !parent.is_on_floor():
		return falling_state

	return null
