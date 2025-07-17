extends State

@export_category("Exit States")
@export var standing_state: State
@export var walking_state: State

@onready var v_audio: Array = sound_database.db['voice']['effort']

func enter() -> void:
	super()

	if !voice_audio.playing:
		voice_audio.stream = v_audio.pick_random()
		voice_audio.play()


func exit() -> void:
	super()


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		parent.position.x += 14 if wall_body_check.get_collision_normal(0)[0] < 0 else -14
		parent.position.y -= 40

		if direction().x == 0:
			state_machine.change_state(standing_state)
		else:
			state_machine.change_state(walking_state)
