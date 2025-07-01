extends State

@export var ladder_climb_state: State

func enter() -> void:
	parent.velocity = Vector2.ZERO
	parent.position.y += 45
	animations.play_backwards(animation_name)

func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		%StateMachine.change_state(ladder_climb_state)
