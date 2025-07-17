extends State

@export var standing_state: State


func enter() -> void:
	super()

	parent.velocity = Vector2.ZERO


func exit() -> void:
	enable_ladder_collision(false)


func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		parent.position.y -= 40
		state_machine.change_state(standing_state)


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
