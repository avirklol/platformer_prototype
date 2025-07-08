extends State


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	if animations.flip_h:
		flip_animations(false)
	else:
		flip_animations(true)
	super()
	parent.velocity = Vector2.ZERO

func _on_animation_finished() -> void:
	if animations.animation == animation_name:
		get_tree().reload_current_scene()
