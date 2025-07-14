extends Node

@export var starting_state: State

var current_state: State
var previous_state: State
var next_state: State


# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(
		parent: CharacterBody2D, animations: AnimatedSprite2D,
		effects: AnimatedSprite2D, input_handler: Node,
		body_audio: AudioStreamPlayer2D, voice_audio: AudioStreamPlayer2D,
		stats: PlayerStats
		) -> void:
	for child in get_children():
		child.parent = parent
		child.animations = animations
		child.effects = effects
		child.input_handler = input_handler
		child.stats = stats
		child.body_audio = body_audio
		child.voice_audio = voice_audio
		child.animations.animation_finished.connect(child._on_animation_finished)
		%LadderRelease.timeout.connect(child._on_ladder_release_timeout)

	# Initialize to the default state
	change_state(starting_state)


# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	previous_state = current_state
	next_state = new_state  # This is a pretty crucial assignment since some exit() methods on states (see three lines below this) will execute different operations if exiting to a specific state.

	if current_state:
		current_state.exit()

	current_state = next_state
	current_state.enter()
	print(current_state.name)


# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
