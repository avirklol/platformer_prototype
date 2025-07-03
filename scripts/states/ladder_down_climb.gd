extends State

@export var ladder_climb_state: State


func enter() -> void:
	parent.velocity = Vector2.ZERO
	enable_ladder_collision(true)
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


func enable_ladder_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		# Disabled ShapeCasts
		%WallSlideCheck.enabled = false
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
		# Enabled CollisionShapes
		%LadderCollision.disabled = false
	else:
		# Enabled CollisionShapes
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		# Enabled ShapeCasts
		%WallSlideCheck.enabled = true
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
		# Disabled CollisionShapes
		%LadderCollision.disabled = true
