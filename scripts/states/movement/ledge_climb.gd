extends State

@export var standing_state: State
@export var walking_state: State

func enter() -> void:
	super()


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		parent.position.x += 14 if %WallBodyCheck.get_collision_normal(0)[0] < 0 else -14
		parent.position.y -= 40
		if direction().x == 0:
			%StateMachine.change_state(standing_state)
		else:
			%StateMachine.change_state(walking_state)
