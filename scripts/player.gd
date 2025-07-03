class_name Player
extends CharacterBody2D

@onready var animations: AnimatedSprite2D = $PlayerAnimations
@onready var effects: AnimatedSprite2D = %Effects
@onready var state_machine: Node = $StateMachine
@onready var input_handler: Node = $InputHandler
var current_ladder: Area2D = null


func _ready() -> void:
	state_machine.init(self, animations, effects, input_handler)
	add_to_group("characters")


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

# Ugly Debug Prints

	print(
	# "LedgeCheck: " + str(%HeadCheck.is_colliding()).to_upper() +
	# " --- " +
	# "WBC: " + str(%WallBodyCheck.is_colliding()).to_upper() +
	# " --- " +
	# "WBC ColNorm: " + (str(%WallBodyCheck.get_collision_normal(0)[0]) if %WallBodyCheck.is_colliding() else "N/A") +
	# " --- " +
	# "RC: " + str(%RunCheck.is_colliding()).to_upper() +
	# " --- " +
	# "FC: " + str(%FloorCheck.is_colliding()).to_upper() +
	# " --- " +
	# # "TC: " + str(%TopCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "TC ColNorm: " + (str(%TopCheck.get_collision_normal(0)[0]) if %TopCheck.is_colliding() else "N/A") +
	# # " --- " +
	# "LTC: " + str(%LadderTopCheck.is_colliding()).to_upper() +
	# " --- " +
	# "LTC ColNorm: " + (str(%LadderTopCheck.get_collision_normal(0)) if %LadderTopCheck.is_colliding() else "N/A") +
	# " --- " +
	# "LBC: " + str(%LadderBottomCheck.is_colliding()).to_upper() +
	# " --- " +
	# "LBC ColNorm: " + (str(%LadderBottomCheck.get_collision_normal(0)) if %LadderBottomCheck.is_colliding() else "N/A") +
	# " --- " +
	# "DC: " + str(%DownClimbCheck.is_colliding()).to_upper() +
	# " --- " +
	# "DC ColNorm: " + (str(%DownClimbCheck.get_collision_normal(0)) if %DownClimbCheck.is_colliding() else "N/A") +
	# " --- " +
	# "OF: " + str(is_on_floor()).to_upper()
	)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
