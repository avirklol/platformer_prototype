class_name State
extends Node

@export var animation_name: String
@export var effect_name: String

@export_category("Audio")
@export var surfaces: Dictionary = {
	"dirt": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"grass": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"gravel": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"leaves": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"metal": {
		"pitch_scale": 1.4,
		"volume_db": -23.0
	},
	"mud": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"rock": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"sand": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"snow": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"tile": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"water": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"wood": {
		"pitch_scale": 1.2,
		"volume_db": -10.0
	},
	"default": {
		"pitch_scale": 2.0,
		"volume_db": 0.0
	}
}

# Collision Shapes
@onready var main_collision: CollisionShape2D = %MainCollision
@onready var ladder_collision: CollisionShape2D = %LadderCollision
@onready var wall_slide_collision: CollisionShape2D = %WallSlideCollision
@onready var crouch_collision: CollisionShape2D = %CrouchCollision
@onready var ledge_grab: CollisionShape2D = %LedgeGrab
# ShapeCasts
@onready var top_check: ShapeCast2D = %TopCheck
@onready var ladder_top_check: ShapeCast2D = %LadderTopCheck
@onready var ladder_bottom_check: ShapeCast2D = %LadderBottomCheck
@onready var jump_check: ShapeCast2D = %JumpCheck
@onready var down_climb_check: ShapeCast2D = %DownClimbCheck
@onready var against_wall_check: ShapeCast2D = %AgainstWallCheck
@onready var floor_check: ShapeCast2D = %FloorCheck
@onready var head_check: ShapeCast2D = %HeadCheck
@onready var run_check: ShapeCast2D = %RunCheck
@onready var wall_slide_check: ShapeCast2D = %WallSlideCheck
@onready var wall_body_check: ShapeCast2D = %WallBodyCheck
@onready var crouch_wall_body_check: ShapeCast2D = %CrouchWallBodyCheck
# Timers
@onready var ladder_release: Timer = %LadderRelease
# Camera
@onready var camera: Camera2D = %Camera2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var parent: CharacterBody2D
var state_machine: StateMachine
var animations: AnimatedSprite2D
var effects: AnimatedSprite2D
var input_handler: Node
var body_audio: AudioStreamPlayer2D
var voice_audio: AudioStreamPlayer2D
var stats: PlayerStats


func _on_animation_finished() -> void:
	pass


func _on_ladder_release_timeout() -> void:
	disable_main_collision(false)
	disable_ladder_shapes(false)


func enter() -> void:
	animations.play(animation_name)


func exit() -> void:
	body_audio.stop()
	voice_audio.stop()


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
	var ledge_grab_pos = ledge_grab.position
	var wall_slide_pos = wall_slide_collision.position
	ledge_grab_pos.x = -abs(ledge_grab_pos.x) if flip else abs(ledge_grab_pos.x)
	wall_slide_pos.x = -abs(wall_slide_pos.x) if flip else abs(wall_slide_pos.x)
	ledge_grab.position = ledge_grab_pos
	wall_slide_collision.position = wall_slide_pos

	# Flip ShapeCasts
	var down_climb_pos = down_climb_check.target_position
	var down_climb_shape_pos = down_climb_check.position
	var head_check_pos = head_check.target_position
	var run_check_pos = run_check.target_position
	var against_wall_check_pos = against_wall_check.target_position
	head_check_pos.x = -abs(head_check_pos.x) if flip else abs(head_check_pos.x)
	run_check_pos.x = -abs(run_check_pos.x) if flip else abs(run_check_pos.x)
	down_climb_pos.x = abs(down_climb_pos.x) if flip else -abs(down_climb_pos.x)
	down_climb_shape_pos.x = abs(down_climb_shape_pos.x) if flip else -abs(down_climb_shape_pos.x)
	against_wall_check_pos.x = -abs(against_wall_check_pos.x) if flip else abs(against_wall_check_pos.x)
	against_wall_check.target_position = against_wall_check_pos
	down_climb_check.target_position = down_climb_pos
	down_climb_check.position = down_climb_shape_pos
	head_check.target_position = head_check_pos
	run_check.target_position = run_check_pos


func disable_ladder_shapes(disable: bool, time: float = 0.5) -> void:
	if disable:
		ladder_release.start(time)
		ladder_top_check.enabled = false
		ladder_bottom_check.enabled = false
	else:
		ladder_top_check.enabled = true
		ladder_bottom_check.enabled = true


func disable_main_collision(disable: bool, time: float = 0.2) -> void:
	if disable:
		ladder_release.start(time)
		main_collision.disabled = true
		ledge_grab.disabled = true
		head_check.enabled = false
		wall_body_check.enabled = false
		wall_slide_check.enabled = false
		parent.current_ladder = null
	else:
		main_collision.disabled = false
		ledge_grab.disabled = false
		head_check.enabled = true
		wall_body_check.enabled = true
		wall_slide_check.enabled = true


func pushing_wall(shapecast, x_direction) -> bool:
	if shapecast.is_colliding():
		if (shapecast.get_collision_normal(0)[0] < 0 and x_direction > 0) or (shapecast.get_collision_normal(0)[0] > 0 and x_direction < 0):
			return true

	return false
