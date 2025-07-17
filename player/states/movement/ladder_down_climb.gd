extends State

@export_category("Exit States")
@export var ladder_climb_state: State


func enter() -> void:
	enable_ladder_collision(true)
	center_player()

	parent.velocity = Vector2.ZERO
	parent.position.y += 45

	animations.play_backwards(animation_name)


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		state_machine.change_state(ladder_climb_state)


func center_player() -> void:
	var ladder = parent.current_ladder

	if ladder:
		var ladder_position = ladder.global_position
		# var ladder_size = ladder.get_node("CollisionShape2D").shape.size

		parent.global_position.x = ladder_position.x


func enable_ladder_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		main_collision.disabled = true
		ledge_grab.disabled = true
		# Disabled ShapeCasts
		wall_slide_check.enabled = false
		head_check.enabled = false
		wall_body_check.enabled = false
		# Enabled CollisionShapes
		ladder_collision.disabled = false
	else:
		# Enabled CollisionShapes
		main_collision.disabled = false
		ledge_grab.disabled = false
		# Enabled ShapeCasts
		wall_slide_check.enabled = true
		head_check.enabled = true
		wall_body_check.enabled = true
		# Disabled CollisionShapes
		ladder_collision.disabled = true
