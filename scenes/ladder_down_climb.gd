extends State

@export var ladder_climb_state: State

func enter() -> void:
	parent.velocity = Vector2.ZERO
	parent.position.y += 45
	center_player()
	animations.play_backwards(animation_name)

func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		%StateMachine.change_state(ladder_climb_state)

func center_player() -> void:
	var ladder = parent.current_ladder
	if ladder:
		var ladder_position = ladder.global_position
		# var ladder_size = ladder.get_node("CollisionShape2D").shape.size

		parent.global_position.x = ladder_position.x
