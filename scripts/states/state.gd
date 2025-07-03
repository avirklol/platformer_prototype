class_name State
extends Node

@export var animation_name: String

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var animations: AnimatedSprite2D
var effects: AnimatedSprite2D
var input_handler: Node
var parent: CharacterBody2D


func _on_animation_finished() -> void:
	pass


func _on_ladder_release_timeout() -> void:
	disable_main_collision(false)
	disable_ladder_shapes(false)


func enter() -> void:
	animations.play(animation_name)


func exit() -> void:
	pass


func process_input(event: InputEvent) -> State:
	return null


func process_frame(delta: float) -> State:
	return null


func process_physics(delta: float) -> State:
	return null


func direction() -> Vector2:
	return input_handler.direction()


func jumping() -> bool:
	return input_handler.jumping()


func crouch_toggle() -> bool:
	return input_handler.crouch_toggle()


func running() -> bool:
	return input_handler.running()


# ANIMATION HANDLING
func flip_animations(flip: bool) -> void:
	animations.flip_h = flip
	effects.flip_h = flip


# COLLISION HANDLING
func flip_collision_shapes(flip: bool) -> void:
	# Flip Collision Shapes
	var ledge_grab_pos = %LedgeGrab.position
	var wall_slide_pos = %WallSlideCollision.position
	ledge_grab_pos.x = -abs(ledge_grab_pos.x) if flip else abs(ledge_grab_pos.x)
	wall_slide_pos.x = -abs(wall_slide_pos.x) if flip else abs(wall_slide_pos.x)
	%LedgeGrab.position = ledge_grab_pos
	%WallSlideCollision.position = wall_slide_pos

	# Flip ShapeCasts
	var down_climb_pos = %DownClimbCheck.target_position
	var down_climb_shape_pos = %DownClimbCheck.position
	var head_check_pos = %HeadCheck.target_position
	var run_check_pos = %RunCheck.target_position
	var against_wall_check_pos = %AgainstWallCheck.target_position
	head_check_pos.x = -abs(head_check_pos.x) if flip else abs(head_check_pos.x)
	run_check_pos.x = -abs(run_check_pos.x) if flip else abs(run_check_pos.x)
	down_climb_pos.x = abs(down_climb_pos.x) if flip else -abs(down_climb_pos.x)
	down_climb_shape_pos.x = abs(down_climb_shape_pos.x) if flip else -abs(down_climb_shape_pos.x)
	against_wall_check_pos.x = -abs(against_wall_check_pos.x) if flip else abs(against_wall_check_pos.x)
	%AgainstWallCheck.target_position = against_wall_check_pos
	%DownClimbCheck.target_position = down_climb_pos
	%DownClimbCheck.position = down_climb_shape_pos
	%HeadCheck.target_position = head_check_pos
	%RunCheck.target_position = run_check_pos


func disable_ladder_shapes(disable: bool, time: float = 0.5) -> void:
	if disable:
		%LadderRelease.start(time)
		%LadderTopCheck.enabled = false
		%LadderBottomCheck.enabled = false
	else:
		%LadderTopCheck.enabled = true
		%LadderBottomCheck.enabled = true


func disable_main_collision(disable: bool, time: float = 0.2) -> void:
	if disable:
		%LadderRelease.start(time)
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
		%WallSlideCheck.enabled = false
		parent.current_ladder = null
	else:
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
		%WallSlideCheck.enabled = true


func pushing_wall(shapecast, x_direction) -> bool:
	if shapecast.is_colliding():
		if (shapecast.get_collision_normal(0)[0] < 0 and x_direction > 0) or (shapecast.get_collision_normal(0)[0] > 0 and x_direction < 0):
			return true

	return false
