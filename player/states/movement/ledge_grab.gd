extends State

@export var hanging_state: State


func enter() -> void:
	super()

	parent.velocity = Vector2.ZERO


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		state_machine.change_state(hanging_state)
