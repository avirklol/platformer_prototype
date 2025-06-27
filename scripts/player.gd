class_name Player
extends CharacterBody2D

@onready
var animations: AnimatedSprite2D = $PlayerAnimations
@onready
var effects: AnimatedSprite2D = %Effects
@onready
var state_machine: Node = $StateMachine
@onready
var input_handler: Node = $InputHandler

func _ready() -> void:
	state_machine.init(self, animations, effects, input_handler)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

# Ugly Debug Prints

	# print("LedgeCheck: " + str(%HeadCheck.is_colliding()).to_upper() +
	# " --- " +
	# "WallBodyCheck: " + str(%WallBodyCheck.is_colliding()).to_upper() +
	# " --- " +
	# "FloorCheck: " + str(%FloorCheck.is_colliding()).to_upper() +
	# " --- " +
	# "TopCheck: " + str(%TopCheck.is_colliding()).to_upper() +
	# " --- " +
	# "On Floor: " + str(is_on_floor()).to_upper())

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
