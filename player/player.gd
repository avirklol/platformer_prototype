class_name Player
extends CharacterBody2D

@onready var animations: AnimatedSprite2D = $PlayerAnimations
@onready var effects: AnimatedSprite2D = %Effects
@onready var state_machine: Node = $StateMachine
@onready var input_handler: Node = $InputHandler
@onready var inventory: Inventory = $Inventory
@onready var stats: PlayerStats = $Stats
@onready var floor_check: ShapeCast2D = %FloorCheck
@onready var ledge_grab: CollisionShape2D = %LedgeGrab
@onready var body_audio: AudioStreamPlayer2D = %PlayerBodyAudio
@onready var voice_audio: AudioStreamPlayer2D = %PlayerVoiceAudio

@onready var grass_tile_map: TileMapLayer = %Grass

var current_ladder: Area2D = null
var is_on: String = ""


func _ready() -> void:
	state_machine.init(self, animations, effects, input_handler, body_audio, voice_audio, stats)
	add_to_group("characters")


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	if floor_check.is_colliding():
		var cell_position: Vector2i = grass_tile_map.get_coords_for_body_rid(floor_check.get_collider_rid(0))
		var cell_data: TileData = grass_tile_map.get_cell_tile_data(cell_position)

		if cell_data:
			is_on = cell_data.get_custom_data("type")
		else:
			print("No cell data")
			# print("No cell data on " + str(cell_position) + " --- " + str(floor_check.get_collider_rid(0)))

	state_machine.process_physics(delta)
	# print(position)
	# print(cell_position)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	if state_machine.current_state.name != "Falling":
		ledge_grab.disabled = true

# Ugly Debug Prints

	# print(
	# # "LedgeCheck: " + str(%HeadCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "WBC: " + str(%WallBodyCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "WBC ColNorm: " + (str(%WallBodyCheck.get_collision_normal(0)[0]) if %WallBodyCheck.is_colliding() else "N/A") +
	# # " --- " +
	# # "RC: " + str(%RunCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "FC: " + str(%FloorCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # # "TC: " + str(%TopCheck.is_colliding()).to_upper() +
	# # # " --- " +
	# # # "TC ColNorm: " + (str(%TopCheck.get_collision_normal(0)[0]) if %TopCheck.is_colliding() else "N/A") +
	# # # " --- " +
	# # "LTC: " + str(%LadderTopCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "LTC ColNorm: " + (str(%LadderTopCheck.get_collision_normal(0)) if %LadderTopCheck.is_colliding() else "N/A") +
	# # " --- " +
	# # "LBC: " + str(%LadderBottomCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "LBC ColNorm: " + (str(%LadderBottomCheck.get_collision_normal(0)) if %LadderBottomCheck.is_colliding() else "N/A") +
	# # " --- " +
	# # "DC: " + str(%DownClimbCheck.is_colliding()).to_upper() +
	# # " --- " +
	# # "DC ColNorm: " + (str(%DownClimbCheck.get_collision_normal(0)) if %DownClimbCheck.is_colliding() else "N/A") +
	# # " --- " +
	# # "OF: " + str(is_on_floor()).to_upper()
	# )
