class_name State
extends Node

@export var animation_name: String
@export var move_speed: float = 100

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var animations: AnimatedSprite2D
var effects: AnimatedSprite2D
var input_handler: Node
var parent: CharacterBody2D

func _on_animation_finished() -> void:
	pass


func _on_ledge_release_timeout() -> void:
	disable_ledge_grab(false)


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
	var ledge_check_pos = %HeadCheck.target_position
	var run_check_pos = %RunCheck.target_position
	ledge_check_pos.x = -abs(ledge_check_pos.x) if flip else abs(ledge_check_pos.x)
	run_check_pos.x = -abs(run_check_pos.x) if flip else abs(run_check_pos.x)
	%HeadCheck.target_position = ledge_check_pos
	%RunCheck.target_position = run_check_pos


func enable_crouch_collision(enable: bool) -> void:
	if enable:
		# Disabled
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		%HeadCheck.enabled = false
		%WallBodyCheck.enabled = false
		%WallSlideCollision.disabled = true
		%WallSlideCheck.enabled = false
		# Enabled
		%CrouchWallBodyCheck.enabled = true
		%CrouchCollision.disabled = false
		# Resize
		%TopCheck.shape.size.x = 17
	else:
		# Enabled
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		%HeadCheck.enabled = true
		%WallBodyCheck.enabled = true
		%WallSlideCheck.enabled = true
		%WallSlideCollision.disabled = true
		# Disabled
		%CrouchWallBodyCheck.enabled = false
		%CrouchCollision.disabled = true
		# Resize
		%TopCheck.shape.size.x = 20


func enable_wall_slide_collision(enable: bool) -> void:
	if enable:
		%MainCollision.disabled = true
		%LedgeGrab.disabled = true
		%HeadCheck.enabled = false
		%WallSlideCollision.disabled = false

	else:
		%MainCollision.disabled = false
		%LedgeGrab.disabled = false
		%HeadCheck.enabled = true
		%WallSlideCollision.disabled = true


func disable_ledge_grab(disable: bool, time: float = 0.5) -> void:
	if disable:
		%LedgeRelease.start(time)
		%LedgeGrab.disabled = true
		%HeadCheck.enabled = false
		%FloorCheck.enabled = false
		%TopCheck.enabled = false
	else:
		%LedgeGrab.disabled = false
		%HeadCheck.enabled = true
		%FloorCheck.enabled = true
		%TopCheck.enabled = true


func pushing_wall(shapecast, x_direction) -> bool:
	if shapecast.is_colliding():
		if (shapecast.get_collision_normal(0)[0] < 0 and x_direction > 0) or (shapecast.get_collision_normal(0)[0] > 0 and x_direction < 0):
			print("Player against wall")
			return true
	return false
