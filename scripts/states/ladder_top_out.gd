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
		%StateMachine.change_state(standing_state)


func enable_ladder_collision(enable: bool) -> void:
	if enable:
		# Disabled CollisionShapes
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		# Disabled ShapeCasts
		%WallSlideCheck.enabled = false
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
	else:
		# Enabled CollisionShapes
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		# Enabled ShapeCasts
		%WallSlideCheck.enabled = true
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
